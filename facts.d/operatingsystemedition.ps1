$OSEdition = Get-WmiObject -Class Win32_OperatingSystem | Select-Object -expand OperatingSystemSKU
    # 1: Ultimate
    # 3: Home Premium
    # 4: Enterprise
    # 7: Standard Server 
    # 10: Entreprise Server 
    # 48: Pro
    # 101: "Windows 8" (i.e. Home)
switch ($OSEdition) {
    1   { Write-Host "operatingsystemedition=Ultimate" }
    3   { Write-Host "operatingsystemedition=Home Premium" }
    4   { Write-Host "operatingsystemedition=Enterprise" }
    7   { Write-Host "operatingsystemedition=Standard Server" }
    10  { Write-Host "operatingsystemedition=Enterprise Server" }
    48  { Write-Host "operatingsystemedition=Professional" }
    101 { Write-Host "operatingsystemedition=Home" }
    default { Write-Host "operatingsystemedition=unknown" }
}
