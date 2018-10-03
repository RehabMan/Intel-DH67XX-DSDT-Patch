#!/bin/bash
#set -x

EXCEPTIONS=
ESSENTIAL="AppleALC.kext"

# include subroutines
source "$(dirname ${BASH_SOURCE[0]})"/_tools/_install_subs.sh

warn_about_superuser

# install tools
install_tools

# remove old kexts
remove_deprecated_kexts

# using AppleALC.kext, remove patched zml.zlib files and CodecCommander.kext
sudo rm -f /System/Library/Extensions/AppleHDA.kext/Contents/Resources/*.zml.zlib
remove_kext CodecCommander.kext

# install required kexts
install_download_kexts
install_brcmpatchram_kexts

# all kexts are now installed, so rebuild cache
rebuild_kernel_cache

# update kexts on EFI/CLOVER/kexts/Other
update_efi_kexts

#EOF
