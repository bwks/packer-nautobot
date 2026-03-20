variable "ubuntu_iso_url" {
  type        = string
  description = "Ubuntu 24.04 cloud image URL"
  default     = "https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
}

variable "ubuntu_iso_checksum" {
  type        = string
  description = "Checksum for the Ubuntu 24.04 cloud image (file: URL to SHA256SUMS)"
  default     = "file:https://cloud-images.ubuntu.com/noble/current/SHA256SUMS"
}

variable "output_directory" {
  type        = string
  description = "Output directory for the built image"
  default     = "output"
}

variable "vm_name" {
  type        = string
  description = "Output image filename (without extension)"
  default     = "nautobot"
}

variable "disk_size" {
  type        = string
  description = "Disk size in megabytes (default 20GB, sparse qcow2)"
  default     = "20480"
}

variable "memory" {
  type        = number
  description = "Memory in megabytes for the build VM"
  default     = 4096
}

variable "cpus" {
  type        = number
  description = "Number of CPUs for the build VM"
  default     = 2
}

variable "accelerator" {
  type        = string
  description = "QEMU accelerator: kvm (Linux), hvf (macOS), or none"
  default     = "kvm"
}

variable "ssh_username" {
  type    = string
  default = "ubuntu"
}

variable "ssh_password" {
  type      = string
  default   = "ubuntu"
  sensitive = true
}
