# Show allocated virtual disks of all Hyper-V VMs
# tested on Hyper-V Server 2016 Host

# Based on: https://social.technet.microsoft.com/Forums/en-US/8696598e-dbf6-4a47-9873-a490ecf0f737/get-storage-drives-info-for-all-vms-in-a-given-cluster
# The "12" and "14" are paddings that must match their label text length
foreach ($vm in Get-VM) { Get-VHD -vmid $vm.vmid  | `
          select @{N="Name";E={$VM.Name}}, `
                 @{N="VHDPath";E={$_.path}}, `
                 @{N="Capacity(GB)";E={ "{0,12:N2}" -f ($_.Size/ 1GB)}}, `
                 @{N="Used Space(GB)";E={"{0,14:N2}" -f ($_.FileSize/ 1GB)}} }
