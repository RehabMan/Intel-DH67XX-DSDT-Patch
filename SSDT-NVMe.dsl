// add an ACPI identity for built-in NVMe SSD in PCIe adapter at _SB.PCI0.POP1.SSD0
DefinitionBlock("", "SSDT", 2, "hack", "nvme", 0)
{
    External(_SB_.PCI0.P0P1, DeviceObj)
    Scope(_SB.PCI0.P0P1)
    {
        Device(SSD0)
        {
            Name(_ADR, Zero)
        }
    }
}
