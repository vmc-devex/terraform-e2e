

terraform {
  backend "local" {
    path = "../../phase3.tfstate"
  }
}
# Import the state from phase 1and 2 and read the outputs
data "terraform_remote_state" "phase1" {
  backend = "local" 
  config = {
    path    = "../../phase1.tfstate"
  }
}
data "terraform_remote_state" "phase2" {
  backend = "local" 
  config = {
    path    = "../../phase2.tfstate"
  }
}

provider "vsphere" {
  user                  = data.terraform_remote_state.phase1.outputs.cloud_username
  password              = data.terraform_remote_state.phase1.outputs.cloud_password
  vsphere_server        = data.terraform_remote_state.phase1.outputs.vc_url
  allow_unverified_ssl  = true
}

provider "nsxt" {
  host                  = data.terraform_remote_state.phase1.outputs.proxy_url
  vmc_token             = var.vmc_token
  allow_unverified_ssl  = true
  enforcement_point     = "vmc-enforcementpoint"
}

/*=====================================
Deploy Virtual Machines and NSX tag them
======================================*/

module "VMs" {
  source = "../VMs"

  data_center         = var.data_center
  cluster             = var.cluster
  workload_datastore  = var.workload_datastore
  compute_pool        = var.compute_pool
  Subnet12_name       = data.terraform_remote_state.phase2.outputs.segment12_name
  subnet12            = data.terraform_remote_state.phase2.outputs.subnet12
  Subnet13_name       = data.terraform_remote_state.phase2.outputs.segment13_name
  subnet13            = data.terraform_remote_state.phase2.outputs.subnet13
}

