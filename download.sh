#set -x

function download()
{
    echo "downloading $2:"
    curl --location --silent --output /tmp/org.rehabman.brix-download.txt https://bitbucket.org/RehabMan/$1/downloads
    scrape=`grep -o -m 1 href\=\".*$2.*\.zip.*\" /tmp/org.rehabman.brix-download.txt|perl -ne 'print $1 if /href\=\"(.*)\"/'`
    url=https://bitbucket.org$scrape
    echo $url
    if [ "$3" == "" ]; then
        curl --remote-name --progress-bar --location "$url"
    else
        curl --output "$3" --progress-bar --location "$url"
    fi
    echo
}

if [ ! -d ./downloads ]; then mkdir ./downloads; fi && rm -Rf downloads/* && cd ./downloads

# download kexts
mkdir ./kexts && cd ./kexts
download os-x-fakesmc-kozlek RehabMan-FakeSMC
download os-x-intel-network RehabMan-IntelMausiEthernet
download os-x-eapd-codec-commander RehabMan-CodecCommander
#download os-x-usb-inject-all RehabMan-USBInjectAll
#download os-x-generic-usb3 RehabMan-Generic-USB3
cd ..

# download tools
mkdir ./tools && cd ./tools
download os-x-maciasl-patchmatic RehabMan-patchmatic
download os-x-maciasl-patchmatic RehabMan-MaciASL
download acpica iasl iasl.zip
cd ..

