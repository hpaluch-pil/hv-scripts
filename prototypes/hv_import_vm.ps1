# This TEMPLATE script will import and rename VM including VHDX HardDisk file

# Example Usage:
# .\hv_import_vm.ps1 "C:\EXPORTS\debian10-efi\Virtual Machines\A01581F6-157C-4489-9A9E-6D67B6622664.vmcx" "debian10-efi3"

# Bugs/Limitations
# - only 1st HDD is handled/renamed

 param (
    [Parameter(Mandatory=$true, HelpMessage="Pathname to *.vmcx file to import (from exported VM)")][string]$import_vmfile,
    [Parameter(Mandatory=$true, HelpMessage="Final imported VM name")][string]$new_vmname
 )

# You may likely customize this variable...
$temp_vhdx_dir = 'C:\TEMP'

# Stop on error in cmdlets
$ErrorActionPreference = "Stop"


$VhdTargetPath = Get-VMHost | select -ExpandProperty VirtualHardDiskPath
$new_vhdx_name="$new_vmname.vhdx"
$new_vhdx = Join-Path $VhdTargetPath $new_vhdx_name

Write-Host "Will import:"
Write-Host " - VM File: '$import_vmfile'"
Write-Host " - Final VM Name: '$new_vmname'"

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
       -VhdDestinationPath $temp_vhdx_dir -Copy -GenerateNewId

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
get-vm -Id $vmid | select -ExpandProperty HardDrives CreationTime `
        | select VMName,VmId,Path,CreationTime
