# This TEMPLATE script will import and rename VM including VHDX HardDisk file

# Bugs/Limiations:
# - only 1st HDD handled/renamed

# These variables must be customized before run
$new_vmname = "debian10-efi11"
$import_vmfile = 'C:\EXPORTS\debian10-efi\Virtual Machines\A01581F6-157C-4489-9A9E-6D67B6622664.vmcx'

$temp_vhdx_dir = 'C:\TEMP'
# Stop on error in cmdlets
$ErrorActionPreference = "Stop"


$VhdTargetPath = Get-VMHost | select -ExpandProperty VirtualHardDiskPath
echo "VHD Target PATH: $VhdTargetPath"
$new_vhdx_name="$new_vmname.vhdx"
$new_vhdx = Join-Path $VhdTargetPath $new_vhdx_name

# basic sanity checks
if ( get-vm | where-object VMName -eq $new_vmname ){
	Write-Error "Target VM '$new_vmname' already exist" `
                    -Category ResourceExists -ErrorAction Stop
}

if ( Test-Path $new_vhdx -PathType Leaf ){
	Write-Error -Message "Target VHDX file '$new_vhdx' already exist" `
                    -Category ResourceExists -ErrorAction Stop
}

if ( -not ( Test-Path $temp_vhdx_dir -PathType Container ) ){
	Write-Host "Creating temporary VHDX directory '$temp_vhdx_dir'..."
	New-Item -Path $temp_vhdx_dir -ItemType Directory
}

# like set -x in bash
Set-PSDebug -Trace 1

$vm = Import-VM -Path  $import_vmfile `
       -VhdDestinationPath c:\TEMP\ -Copy -GenerateNewId

$vmid = $vm.VmId.ToString()
Write-Host "Imported VmId='$vmid'"
# rename-vm to avoid lot of confussion...
Rename-VM -VM $vm -NewName $new_vmname
# verify that it was renamed
Get-Vm -Id $vmid
# warning - this will work for single drive only
$old_vhdx = get-vhd -vmid $vmid
# rename vhdx in same directory (can't be renamed and moved  in one step)
rename-item $old_vhdx.path $new_vhdx_name
move-item (Join-Path $temp_vhdx_dir $new_vhdx_name) $new_vhdx
$vm_hdd = $vm.harddrives[0]
Set-VMHardDiskDrive $vm_hdd -Path $new_vhdx

# like set +x in bash
Set-PSDebug -Trace 0

# show new VM
Write-Host "VM Imported: Id= '$vmid' "
get-vm -Id $vmid | select -ExpandProperty HardDrives `
        | select VMName,VmId,Path,CreationTime
