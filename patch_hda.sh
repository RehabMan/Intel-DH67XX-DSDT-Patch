#!/bin/bash

#set -x

unpatched=/System/Library/Extensions
#unpatched=./

# extract minor version (eg. 10.9 vs. 10.10 vs. 10.11)
MINOR_VER=$([[ "$(sw_vers -productVersion)" =~ [0-9]+\.([0-9]+) ]] && echo ${BASH_REMATCH[1]})

# AppleHDA patching function
function createAppleHDAInjector()
{
# create AppleHDA injector for Clover setup...
    echo -n "Creating AppleHDA injector for $1..."
    rm -Rf AppleHDA_$1.kext
    mkdir AppleHDA_$1.kext
    cp -RX $unpatched/AppleHDA.kext/ AppleHDA_$1.kext
    rm -R AppleHDA_$1.kext/Contents/Resources/*
    rm -R AppleHDA_$1.kext/Contents/PlugIns
    rm -R AppleHDA_$1.kext/Contents/_CodeSignature
    rm -f AppleHDA_$1.kext/Contents/Code*
    rm -R AppleHDA_$1.kext/Contents/MacOS/AppleHDA
    rm AppleHDA_$1.kext/Contents/version.plist
    ln -s /System/Library/Extensions/AppleHDA.kext/Contents/MacOS/AppleHDA AppleHDA_$1.kext/Contents/MacOS/AppleHDA
    layouts=$(basename `ls Resources_$1/layout*.plist`)
    for layout in $layouts; do
        cp Resources_$1/$layout AppleHDA_$1.kext/Contents/Resources/${layout/.plist/.xml}
    done
    if [[ $MINOR_VER -ge 8 ]]; then
        ./tools/zlib inflate $unpatched/AppleHDA.kext/Contents/Resources/Platforms.xml.zlib >/tmp/rm_Platforms.plist
    else
        cp $unpatched/AppleHDA.kext/Contents/Resources/Platforms.xml /tmp/rm_Platforms.plist
    fi
    /usr/libexec/plistbuddy -c "Delete ':PathMaps'" /tmp/rm_Platforms.plist
    /usr/libexec/plistbuddy -c "Merge Resources_$1/Platforms.plist" /tmp/rm_Platforms.plist
    cp /tmp/rm_Platforms.plist AppleHDA_$1.kext/Contents/Resources/Platforms.xml
    if [[ $MINOR_VER -gt 7 ]]; then
        for xml in AppleHDA_$1.kext/Contents/Resources/*.xml; do
            ./tools/zlib deflate $xml >${xml/.xml/.xml.zlib}
            rm $xml
        done
    fi

    # fix versions (must be larger than native)
    plist=AppleHDA_$1.kext/Contents/Info.plist
    pattern='s/(\d*\.\d*(\.\d*)?)/9\1/'
    if [[ $MINOR_VER -ge 10 ]]; then
        replace=`/usr/libexec/plistbuddy -c "Print :NSHumanReadableCopyright" $plist | perl -p -e $pattern`
        /usr/libexec/plistbuddy -c "Set :NSHumanReadableCopyright '$replace'" $plist
    fi
    replace=`/usr/libexec/plistbuddy -c "Print :CFBundleGetInfoString" $plist | perl -p -e $pattern`
    /usr/libexec/plistbuddy -c "Set :CFBundleGetInfoString '$replace'" $plist
    replace=`/usr/libexec/plistbuddy -c "Print :CFBundleVersion" $plist | perl -p -e $pattern`
    /usr/libexec/plistbuddy -c "Set :CFBundleVersion '$replace'" $plist
    replace=`/usr/libexec/plistbuddy -c "Print :CFBundleShortVersionString" $plist | perl -p -e $pattern`
    /usr/libexec/plistbuddy -c "Set :CFBundleShortVersionString '$replace'" $plist
if [ 0 -eq 0 ]; then
    # create AppleHDAHardwareConfigDriver overrides (injector personality)
    /usr/libexec/plistbuddy -c "Add ':HardwareConfigDriver_Temp' dict" $plist
    /usr/libexec/plistbuddy -c "Merge $unpatched/AppleHDA.kext/Contents/PlugIns/AppleHDAHardwareConfigDriver.kext/Contents/Info.plist ':HardwareConfigDriver_Temp'" $plist
    /usr/libexec/plistbuddy -c "Copy ':HardwareConfigDriver_Temp:IOKitPersonalities:HDA Hardware Config Resource' ':IOKitPersonalities:HDA Hardware Config Resource'" $plist
    /usr/libexec/plistbuddy -c "Delete ':HardwareConfigDriver_Temp'" $plist
    /usr/libexec/plistbuddy -c "Delete ':IOKitPersonalities:HDA Hardware Config Resource:HDAConfigDefault'" $plist
    /usr/libexec/plistbuddy -c "Delete ':IOKitPersonalities:HDA Hardware Config Resource:PostConstructionInitialization'" $plist
    /usr/libexec/plistbuddy -c "Add ':IOKitPersonalities:HDA Hardware Config Resource:IOProbeScore' integer" $plist
    /usr/libexec/plistbuddy -c "Set ':IOKitPersonalities:HDA Hardware Config Resource:IOProbeScore' 2000" $plist
    /usr/libexec/plistbuddy -c "Merge ./Resources_$1/ahhcd.plist ':IOKitPersonalities:HDA Hardware Config Resource'" $plist
fi
    echo " Done."
}

if [[ "$1" == "" ]]; then
    echo Usage: patch_hda.sh {codec}
    echo Example: patch_hda.sh ALC892
    exit
fi

createAppleHDAInjector "$1"
