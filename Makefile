.PHONY: init validate build build-debug clean

PACKER_LOG  ?= 0
OUTPUT_DIR  ?= output
IMAGE       ?= $(OUTPUT_DIR)/nautobot.qcow2

# Initialise plugins (run once after checkout)
init:
	packer init nautobot.pkr.hcl

# Validate the template without building
validate: init
	packer validate nautobot.pkr.hcl

# Build the image
build: init
	PACKER_LOG=$(PACKER_LOG) packer build nautobot.pkr.hcl

# Build with full debug logging
build-debug: init
	PACKER_LOG=1 packer build -debug nautobot.pkr.hcl

# Remove build output
clean:
	rm -rf $(OUTPUT_DIR)
	rm -rf /tmp/packer-*

# Quick info about the output image
info:
	@test -f $(IMAGE) && qemu-img info $(IMAGE) || echo "Image not found: $(IMAGE)"
