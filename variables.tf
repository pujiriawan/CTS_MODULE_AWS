variable "aws_region" {
    description = "Region Thales cts Manager will be deployed in."
    type = string
    default = ""
}

#variable "aws_access_id" {
#     description = "Access Key ID"
#     type = string
#}
#
#variable "aws_access_secret" {
#     description = "Access Key Secret"
#     type = string
# }

variable "cts_ami_id" {
    description = "Put AMI ID you get from AWS Marketplace"
    type = string
    default = ""

}

variable "name_instance" {
    description = "Name of intance cts manager"
    type = string
    default = ""
  
}

variable "infra_env" {
    description = "Name of environment CM"
    type = string
    default = ""
}

variable "project_name" {
    description = "Name of Project"
    type = string
    default = ""
}

variable "script_path_ansible" {
    type = string
    description = "this is script for ansible"
    default = ""
}

variable "file_path" {
  type = string
    description = "location of file path connection setting for cm"
    default = ""
}