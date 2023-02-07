#############################################################################
# Environment variable fetching.
#############################################################################
data "external" "env" {
  program = ["python3", "${path.module}/env.py"]
  # For Windows (or Powershell core on MacOS and Linux),
  # run a Powershell script instead
  #program = ["${path.module}/env.ps1"]
}

# Show the results of running the data source. This is a map of environment
# variable names to their values.
# output "GetUser" {
#   value = data.external.env.result["XCP_USER"]
# }

#############################################################################
# Provider configuration for xen orchestra.
#############################################################################
# Instruct terraform to download the provider on `terraform init`
terraform {
  required_providers {
    xenorchestra = {
      source = "terra-farm/xenorchestra"
    }
  }
}

# Configure the XenServer Provider
provider "xenorchestra" {
  # Must be ws or wss
  url      = data.external.env.result["XCP_HOSTNAME"] # Or set XOA_URL environment variable
  username = data.external.env.result["XCP_USER"]     # Or set XOA_USER environment variable
  password = data.external.env.result["XCP_PASSWORD"] # Or set XOA_PASSWORD environment variable

  # This is false by default and
  # will disable ssl verification if true.
  # This is useful if your deployment uses
  # a self signed certificate but should be
  # used sparingly!
  insecure = true # Or set XOA_INSECURE environment variable to any value
}

#############################################################################
# Template, Storage and Networking referencing.
#############################################################################

data "xenorchestra_pool" "pool" {
  name_label = "xeon-server"
}

data "xenorchestra_sr" "smb_arch_sr" {
  name_label = "ISO Files Arch"
}

data "xenorchestra_network" "net" {
  name_label = "Pool-wide network associated with eth0"
}

data "xenorchestra_template" "ubuntu_template" {
  name_label = "Ubuntu Focal Fossa 20.04"
}

#############################################################################
# Ubuntu Server VM configuration.
#############################################################################

resource "xenorchestra_vm" "Minecraft Server" {
  name_label        = "GNS3 VM"
  name_description  = "GNS3 vm for cisco labs."
  memory_max        = 57982058496 #60GB
  cpus              = 12
  template          = data.xenorchestra_template.ubuntu_template.id
  auto_poweron      = true
  exp_nested_hvm    = true
  hvm_boot_firmware = "bios"

  cdrom {
    id = "a52d79ab-304a-42af-97f0-28e5238712d0"
  }

  network {
    network_id = data.xenorchestra_network.net.id
  }

  disk {
    sr_id      = "ef1d6d1e-843d-d387-b6f1-d581ea75b8a2"
    name_label = "GNS3-Disk"
    size       = 26843545600
  }

  tags = [
    "Ubuntu Server 2204",
    "Jammy Jellyfish",
    "Minecraft Server VM",
    "Java"
  ]

  timeouts {
    create = "20m"
  }
}

# xe cd-list => Displays all ISO's available in XCP-ng.
# xe vm-disk-list => Displays all storages assigned to the created VM's.
# xe template-list => Shows all available templates details.
