#!/bin/bash
#set -x

EXCEPTIONS=
ESSENTIAL=
HDA=ALC892

# include subroutines
DIR=$(dirname ${BASH_SOURCE[0]})
source "$DIR/tools/_install_subs.sh"

warn_about_superuser

# install tools
install_tools

# install required kexts
install_download_kexts
remove_deprecated_kexts

# create/install patched AppleHDA files
install_hda

# all kexts are now installed, so rebuild cache
rebuild_kernel_cache

# update kexts on EFI/CLOVER/kexts/Other
update_efi_kexts

#EOF
