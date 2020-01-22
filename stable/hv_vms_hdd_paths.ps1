# List VMs and assigned HDDs
# tested on Hyper-V Server 2016 Host

get-vm | select -ExpandProperty HardDrives | select VMName, ControllerType, Path

