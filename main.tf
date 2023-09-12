provider "aws" {
 region = "us-east-1"
}

# Generate an SSH key. Required to setup cts Manager Instance.
resource "tls_private_key" "cts_ssh_key" {
  algorithm = "RSA"
  rsa_bits = 4096
}

# Creating an instance of cts Manager Community Edition on AWS
# Referece create AMI using this guide : https://thalesdocs.com/ctp/cm/2.7/get_started/deployment/virtual-deployment/aws-deployment/index.html
resource "aws_instance" "cts_aws" {
    ami = var.cts_ami_id
    instance_type = "t2.xlarge"   # Recommended Size
    vpc_security_group_ids = [aws_security_group.ciphertust_network_firewall.id]
    subnet_id = aws_subnet.ciphertust_network_public_subnet.id
    tags = {
            Name = "${var.aws_region}-${var.infra_env}-${var.project_name}-${var.name_instance}"
            Project     = var.project_name
            Environment = var.infra_env
            ManagedBy   = "terraform"
        }
    
    root_block_device {
      volume_size = 100   # Recommended size to run cts Manager in production
      volume_type = "gp2"   # For higher volume transactions, you might want to update the type of EBS volume.
    }
}

# Generate cts Connection node for ansible
resource "local_file" "connection_node" {
depends_on = [aws_instance.cts_aws]
filename = var.file_path
content = <<EOF
this_node_address: ${aws_instance.cts_aws.public_ip}
this_node_private_ip: ${aws_instance.cts_aws.public_ip}
this_node_username: admin
this_default_password: admin
this_node_password: P@ssw0rd.1!
this_node_connection_string:
  server_ip: "{{ this_node_address }}"
  server_private_ip: "{{ this_node_private_ip }}"
  server_port: 5432
  user: "{{ this_node_username }}"
  password: "{{ this_node_password }}"
  verify: False
EOF
}


# This is ansible playbook will call ansible collection create by Thales Team https://github.com/thalescpl-io/CDSP_Orchestration
resource "null_resource" "change_initial_password" {
    depends_on = [local_file.connection_node]
    provisioner "local-exec" {
    working_dir = var.script_path_ansible
    command = "sleep 600; ansible-playbook resetInitialPassword.yml"
    }
  }


resource "null_resource" "inject_license" {
    depends_on = [null_resource.change_initial_password]
    provisioner "local-exec" {
    working_dir = var.script_path_ansible
    command = "ansible-playbook cts_inject_license.yml"
    #command = "echo 'Succesfully Deploy cts Manager'"
    }
  }