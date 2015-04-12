Write-Host "Checking active Power Plan (should be High Perf 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c)"
$powerPlan=get-wmiobject -namespace "root\cimv2\power" -class Win32_powerplan | where {$_.IsActive}
$powerPlanID = $powerPlan.InstanceID.split("\")[1].trim("{","}")
if($powerPlanID -ne "8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c") { exit 1 }

Write-Host "Checking Power Plan settings"
$powerSettings = $powerPlan.GetRelated("win32_powersettingdataindex")
$expectedSettings = 
@([pscustomobject]@{id="9d7815a6-7ee4-497e-8888-515a05f02364";value=0},
[pscustomobject]@{id="3c0bc021-c8a8-4e07-a973-6b14cbcb2b7e";value=0},
[pscustomobject]@{id="6738e2c4-e8a5-4a42-b16a-e040e769756e";value=0},
[pscustomobject]@{id="29f6c1db-86da-48c5-9fdb-f2b67b1f44da";value=0},
[pscustomobject]@{id="0e796bdb-100d-47d6-a2d5-f7d2daa51f51";value=0});

# For some reason, using a ForEach loop does not work if the block code between {} is not in a single line...
ForEach ($eS in $expectedSettings) { ForEach ($pS in $powerSettings) { $pSid=$pS.instanceid.split("\")[3].trim("{","}"); $pSvalue=$pS.settingindexvalue; if (($pSid -eq $eS.id) -and ($pSvalue -ne $eS.value)) { exit 1 } } }
exit 0