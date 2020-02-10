# List VMs and assigned DVDs
# tested on Hyper-V Server 2012 R2

get-vm | select -ExpandProperty DVDDrives | select VMName, ControllerType, Path

