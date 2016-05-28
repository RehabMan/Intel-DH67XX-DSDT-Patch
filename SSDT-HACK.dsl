// Instead of providing patched DSDT/SSDT, just include a single SSDT
// and do the rest of the work in config.plist

// A bit experimental, but possible as desktops are much simpler vs. laptops
// Becuase of the minimal patches required, we can do most of the work in
// config.plist and small SSDTs such as this one.

DefinitionBlock ("", "SSDT", 2, "hack", "hack", 0)
{
    External(_SB.PCI0, DeviceObj)
    
    // All _OSI calls in DSDT are routed to XOSI...
    // XOSI simulates "Windows 2006" (which is Windows Vista)
    // Note: According to ACPI spec, _OSI("Windows") must also return true
    //  Also, it should return true for all previous versions of Windows.
    Method(XOSI, 1)
    {
        // simulation targets
        // source: (google 'Microsoft Windows _OSI')
        //  http://download.microsoft.com/download/7/E/7/7E7662CF-CBEA-470B-A97E-CE7CE0D98DC2/WinACPI_OSI.docx
        Name(WVL, Package()
        {
            "Windows",              // generic Windows query
            "Windows 2001",         // Windows XP
            "Windows 2001 SP2",     // Windows XP SP2
            //"Windows 2001.1",     // Windows Server 2003
            //"Windows 2001.1 SP1", // Windows Server 2003 SP1
            "Windows 2006",         // Windows Vista
            //"Windows 2006 SP1",   // Windows Vista SP1
            //"Windows 2006.1",     // Windows Server 2008
            //"Windows 2009",       // Windows 7/Windows Server 2008 R2
            //"Windows 2012",       // Windows 8/Windows Server 2012
            //"Windows 2013",       // Windows 8.1/Windows Server 2012 R2
            //"Windows 2015",       // Windows 10/Windows Server TP
        })
        Return (Ones != Match(WVL, MEQ, Arg0, MTR, 0, 0))
    }

    Scope(_SB.PCI0)
    {
        // IOKS does things with a non-existant PS2 port that causes issues with sleep.
        // IOKS is renamed to XOKS in DSDT, so calls to it will land here
        // this version of IOKS does nothing, which avoids the sleep problem.
        External(\_SB.PCI0.SBRG, DeviceObj)
        Method(SBRG.IOKS, 1) { }

        // no HDEF in this DSDT, so add one
        Device(HDEF)
        {
            Name(_ADR, 0x001B0000)
            Name(_PRW, Package() { 0x0d, 0x05 })
        }
    }
}
//EOF
