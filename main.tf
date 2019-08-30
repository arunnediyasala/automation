# Define variable
variable "region" {
default = "us-east-1"
}

# User Variables
provider "aws"{
region     = "${var.region}"
}

variable "tagName" {
default = "ns3_slurm_cluster_test"
}
variable "instcount" {
default = "3"
}
resource "aws_instance" "fb_ns3_cluster_instance"{
 ami  = "ami-067de159f98988344"
 count  = var.instcount
 instance_type = "c5n.2xlarge"
 availability_zone = "us-east-1c"
 key_name = "Enter your key"
 security_groups = ["NYCOffice"]
 cpu_core_count = "4"
 cpu_threads_per_core = "1"

tags = {
Name = var.tagName
Author = "Arun Soman"
TerraformName = "aws_instance"
TerraformType = "compute_instance"
Description = "Ns3 testing"
PlatformName = "None"
}
}
  


output "private_compute"{
    value = "${aws_instance.fb_ns3_cluster_instance.*.private_ip}"
}


