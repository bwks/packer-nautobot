packer {
  required_plugins {
    qemu = {
      source  = "github.com/hashicorp/qemu"
      version = "~> 1"
    }
  }
}

source "qemu" "nautobot" {
  # --- Source image ---
  iso_url      = var.ubuntu_iso_url
  iso_checksum = var.ubuntu_iso_checksum
  disk_image   = true

  # --- Output ---
  output_directory = var.output_directory
  vm_name          = "${var.vm_name}.qcow2"
  format           = "qcow2"

  # --- Disk: sparse provisioned ---
  disk_size       = var.disk_size
  disk_interface  = "virtio"
  disk_discard    = "unmap"
  skip_compaction = true

  # --- Machine ---
  accelerator  = var.accelerator
  machine_type = "q35"
  cpus         = var.cpus
  memory       = var.memory
  headless     = true
  net_device   = "virtio-net"

  # Expose host CPU features (needed for x86-64-v2 wheels like numpy, which
  # nautobot_circuit_maintenance pulls in transitively).
  qemuargs = [
    ["-cpu", "host"],
  ]

  # --- cloud-init NoCloud seed ISO ---
  # Files are placed at the ISO root using their basenames:
  #   cloud-init/user-data  -> user-data
  #   cloud-init/meta-data  -> meta-data
  # Label "cidata" triggers the NoCloud datasource.
  cd_files = [
    "cloud-init/meta-data",
    "cloud-init/user-data",
  ]
  cd_label = "cidata"

  # --- SSH access (configured by cloud-init user-data) ---
  ssh_username           = var.ssh_username
  ssh_password           = var.ssh_password
  ssh_timeout            = "45m"
  ssh_handshake_attempts = 50

  # --- Boot ---
  boot_wait = "5s"

  # --- Shutdown ---
  shutdown_command = "sudo shutdown -P now"
}

build {
  name    = "nautobot"
  sources = ["source.qemu.nautobot"]

  provisioner "shell" {
    execute_command = "chmod +x {{ .Path }}; sudo env {{ .Vars }} {{ .Path }}"
    environment_vars = [
      "DEBIAN_FRONTEND=noninteractive",
      "NAUTOBOT_VERSION=${var.nautobot_version}",
    ]
    scripts = [
      "scripts/00-prepare.sh",
      "scripts/01-install-nautobot.sh",
      "scripts/02-configure-nautobot.sh",
      "scripts/03-cleanup.sh",
    ]
    # Give long-running installs time to complete
    timeout = "90m"
  }
}
