# terraform.tfvars
region = "eu-central-1"

key_name = "azubeq-frankfurt-key"

project_name = "Jenkins"
environment = "stage"
my_ip = "0.0.0.0/0"
j_vpc_cidr = "10.0.0.0/16"
public_subnet_cidr = "10.0.10.0/24"

j_instance_type = "t3.small"
j_volume_size = "18"
j_volume_type = "gp3"


