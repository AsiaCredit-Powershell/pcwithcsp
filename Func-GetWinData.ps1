function Get-WinData {
    param (
        $PC
        )

    if ($null -eq $PC) {
        # Получаем список всех компов
        $PCs = Get-ADComputer -Filter "name -like '*'"
        $PCs = $PCs.name
        }

    else {
        $PCs = Get-ADComputer -Filter "name -like '*$PC*'"
        $PCs = $PCs.name
        }

    if ($PCs.count -gt 1) {
        # С помощью цикла - ищем файл remoteSC.txt
        $DataArray = foreach ($Name in $PCs) {
        $Sysinfo = invoke-command -computername $Name -scriptblock  {
            $systeminfo = Get-CimInstance -ClassName Win32_OperatingSystem -Property *
            $systeminfo
            }
        $Version = $Sysinfo.Version
        $SerialNumber = $Sysinfo.SerialNumber
        $ProductType = $Sysinfo.ProductType
        $OSArchitecture = $Sysinfo.OSArchitecture
        $status = $Sysinfo.status
        $caption = $Sysinfo.caption
        $CSName = $Sysinfo.CSName
        $installdate = $Sysinfo.installdate

        $DataArray  = [pscustomobject]@{ComputerName = "$Name"; Version = "$Version"; SerialNumber = "$SerialNumber"; ProductType = "$ProductType"; OSArchitecture = "$OSArchitecture"; status = "$status"; caption = "$caption"; CSName = "$CSName"; installdate = "$installdate"}
        $DataArray 
            }
        
    else {
        $Sysinfo = invoke-command -computername $Name -scriptblock  {
            $systeminfo = Get-CimInstance -ClassName Win32_OperatingSystem -Property *
            $systeminfo
            }
        $Version = $Sysinfo.Version
        $SerialNumber = $Sysinfo.SerialNumber
        $ProductType = $Sysinfo.ProductType
        $OSArchitecture = $Sysinfo.OSArchitecture
        $status = $Sysinfo.status
        $caption = $Sysinfo.caption
        $CSName = $Sysinfo.CSName
        $installdate = $Sysinfo.installdate

        $DataArray = [pscustomobject]@{ComputerName = "$Name"; Version = "$Version"; SerialNumber = "$SerialNumber"; ProductType = "$ProductType"; OSArchitecture = "$OSArchitecture"; status = "$status"; caption = "$caption"; CSName = "$CSName"; installdate = "$installdate"}
        $DataArray 
            }       
        }
    return $DataArray
    }

