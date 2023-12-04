# Create a region variable containing the list of OVHcloud regions
# It will be used to iterate over different regions in order to
# start an instance on each of them.
 variable "region" {
   type = list
  #  default = ["GRA11", "BHS5"]
  #  default = ["GRA11"]
   default = ["BHS5"]
 }


# Creating an SSH key pair resource
resource "openstack_compute_keypair_v2" "cluster_kube_key_terraform" {
  count = length(var.region)
  provider   = openstack.ovh # Provider name declared in provider.tf
  name       = "cluster_kube_key" # Name of the SSH key to use for creation
  public_key = file("/Users/ninapepite/Downloads/Aidalinfo/id_ovh_cloud.pub") # Path to your previously generated SSH key
  region = element(var.region, count.index)
}

# Creating the instance
resource "openstack_compute_instance_v2" "kube_tf_control_panel" {
   # Number of times the resource will be created
   # defined by the length of the list named region
  count = length(var.region)
  name        = "kube_control_panel_terraform" # Instance name
  provider    = openstack.ovh  # Provider name
  image_name  = "Ubuntu 23.04 - UEFI" # Image name
  region = element(var.region, count.index)
  flavor_name = "d2-4" # Instance type name
  # Name of openstack_compute_keypair_v2 resource named keypair_test
  key_pair = element(openstack_compute_keypair_v2.cluster_kube_key_terraform.*.name, count.index)
  network {
    name      = "Ext-Net" # Adds the network component to reach your instance
  }
  user_data = <<-EOF
            #!/bin/bash
            sudo apt-get update -y
            sudo apt-get install -y git
            git clone https://github.com/Killian-Aidalinfo/tf-toolbox.git
            cd tf-toolbox
            chmod +x setup_k8s.sh
            ./setup_k8s.sh
            EOF
}

# # Creating the instance
# resource "openstack_compute_instance_v2" "kube_tf_node1" {
#    # Number of times the resource will be created
#    # defined by the length of the list named region
#   count = length(var.region)
#   name        = "kube_tf_node1_terraform" # Instance name
#   provider    = openstack.ovh  # Provider name
#   image_name  = "Debian 12" # Image name
#   region = element(var.region, count.index)
#   flavor_name = "d2-4" # Instance type name
#   # Name of openstack_compute_keypair_v2 resource named keypair_test
#   key_pair = element(openstack_compute_keypair_v2.cluster_kube_key_terraform.*.name, count.index)
#   network {
#     name      = "Ext-Net" # Adds the network component to reach your instance
#   }
#   user_data = <<-EOF
#           #!/bin/bash
#           sudo apt-get update -y
#           sudo apt-get install -y git
#           git clone https://github.com/Killian-Aidalinfo/tf-toolbox.git
#           cd tf-toolbox
#           chmod +x setup_k8s.sh
#           ./setup_k8s.sh
#           EOF
# }

# # Creating the instance
# resource "openstack_compute_instance_v2" "kube_tf_node2" {
#    # Number of times the resource will be created
#    # defined by the length of the list named region
#   count = length(var.region)
#   name        = "kube_tf_node2_terraform" # Instance name
#   provider    = openstack.ovh  # Provider name
#   image_name  = "Debian 12" # Image name
#   region = element(var.region, count.index)
#   flavor_name = "d2-4" # Instance type name
#   # Name of openstack_compute_keypair_v2 resource named keypair_test
#   key_pair = element(openstack_compute_keypair_v2.cluster_kube_key_terraform.*.name, count.index)
#   network {
#     name      = "Ext-Net" # Adds the network component to reach your instance
#   }
#   user_data = <<-EOF
#           #!/bin/bash
#           sudo apt-get update -y
#           sudo apt-get install -y git
#           git clone https://github.com/Killian-Aidalinfo/tf-toolbox.git
#           cd tf-toolbox
#           chmod +x setup_k8s.sh
#           ./setup_k8s.sh
#           EOF
# }
