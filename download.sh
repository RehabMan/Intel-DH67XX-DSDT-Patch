#!/bin/bash
#set -x

# get copy of tools
"$(dirname ${BASH_SOURCE[0]})"/_get_tools.sh

# include subroutines
source "$(dirname ${BASH_SOURCE[0]})"/_tools/_download_subs.sh

# remove deprecated downloads directory to avoid confusion
if [[ -e ./downloads ]]; then rm -Rf ./downloads; fi

# create _downloads directory and clean
if [[ ! -d ./_downloads ]]; then mkdir ./_downloads; fi && rm -Rf ./_downloads/* && cd ./_downloads

# download kexts
mkdir ./kexts && cd ./kexts
download_rehabman os-x-fakesmc-kozlek RehabMan-FakeSMC
download_rehabman os-x-intel-network RehabMan-IntelMausiEthernet
download_rehabman os-x-eapd-codec-commander RehabMan-CodecCommander
#download_rehabman os-x-usb-inject-all RehabMan-USBInjectAll
#download_rehabman os-x-generic-usb3 RehabMan-Generic-USB3
cd ..

# download tools
mkdir ./tools && cd ./tools
download_rehabman os-x-maciasl-patchmatic RehabMan-patchmatic
download_rehabman os-x-maciasl-patchmatic RehabMan-MaciASL
download_rehabman acpica iasl iasl.zip
cd ..

