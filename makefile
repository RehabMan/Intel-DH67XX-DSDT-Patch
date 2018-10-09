# makefile

#
# Patches/Installs/Builds DSDT patches for DH67GD
#
# Created by RehabMan 
#

# set build products
BUILDDIR=./build
AML_PRODUCTS=$(BUILDDIR)/SSDT-HACK.aml $(BUILDDIR)/SSDT-NVMe.aml
PRODUCTS=$(AML_PRODUCTS)

IASLFLAGS=-vw 2120 -vw 2146
IASL=iasl

.PHONY: all
all: $(PRODUCTS)

$(BUILDDIR)/SSDT-HACK.aml: ./SSDT-HACK.dsl
	$(IASL) $(IASLFLAGS) -p $@ $<

$(BUILDDIR)/SSDT-NVMe.aml: ./SSDT-NVMe.dsl
	$(IASL) $(IASLFLAGS) -p $@ $<

.PHONY: clean
clean:
	rm -f $(BUILDDIR)/*.dsl $(BUILDDIR)/*.aml

.PHONY: install
install: $(BUILDDIR)/SSDT-HACK.aml
	$(eval EFIDIR:=$(shell ./mount_efi.sh))
	cp $(BUILDDIR)/SSDT-HACK.aml "$(EFIDIR)"/EFI/CLOVER/ACPI/patched

.PHONY: install_nvme
install_nvme: $(BUILDDIR)/SSDT-HACK.aml
	$(eval EFIDIR:=$(shell ./mount_efi.sh))
	cp $(BUILDDIR)/SSDT-HACK.aml "$(EFIDIR)"/EFI/CLOVER/ACPI/patched
	cp $(BUILDDIR)/SSDT-NVMe.aml "$(EFIDIR)"/EFI/CLOVER/ACPI/patched

#EOF
