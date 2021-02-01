<#
    Скрипт необходимый для удаления СК. 
    Работает так: ищется по пути C:\Program Files (x86)\ каталог с наименованием 'screencon*'
    Если он находится, то вызываем MSI "$ConfigPath\ConnectWiseControl.ClientSetupAsia.msi" для удаления
    Если не находится - пишем в лог данные: либо лог удаления, либо лог ненайденного файла $UninstallErrorMSG
    
    Это связано с требованиями ЦБ, дабы на компах, использующихся с крипто про - не было утилит для удаленного доступа
    глядящих в интернет. 
#>

# Настройка переменных 
$ConfigPath = '\\ilc-fileserv\IT\GPO\PCwithCSP'
$UninstallFile = "$ConfigPath\ConnectWiseControl.ClientSetupAsia.msi"
$UninstallLog = "C:\uninstalSC.txt"
$UninstallErrorMSG = "Скринконнект на ПК $env:COMPUTERNAME не обнаружен."
$DirSC = "C:\Program Files (x86)\"
$DirCSP = "C:\Program Files\Crypto Pro\CSP" 

# привязка фалогов на свитч (так легче отслеживать для дебага, нежели if\else 
$SC = Get-ChildItem -Path $DirSC -Filter 'screencon*'
$CSP = Get-ChildItem -Path $DirCSP 
    if ($null -eq $SC -and $null -eq $CSP ) {
        $SwitchFlag = '1'
    }
    else {
        $SwitchFlag = '2'
    }

# Сама выборка. Если переменная = 2, тогда удаляем приложение. Если = 1 -пишем $UninstallErrorMSG в файл лога
Switch ($SwitchFlag) {
    2 {
        & msiexec.exe /x $UninstallFile /QN /L*V "$UninstallLog" REBOOT=R 
        $service = Get-Service -Name "teamviewe*, screencon*" 
        $service | ForEach-Object -Process {
            if (!$service) {
                break
        }
            else { 
                Set-Service -Name $PSItem.name -StartupType Disabled 
                Stop-Process -Name $PSItem.name -Force
            }
        }
      
    1 { $UninstallErrorMSG `
                | Out-File -FilePath $UninstallLog
        }}
        