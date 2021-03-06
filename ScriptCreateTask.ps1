<#
    Задания необходимые для раздачи тасков на машины с CSP
    Требование от ЦБ в том, что бы:
    1. Машины сверяли хэш крипто про
    2. Ребутались раз в сутки
    3. Чистили журнал ошибок по лицензии 
    4. удаляли всякие скринконнекты

    Таск запускает батник bat_cpverify с необходимыми ключами. Батники лежат по пути:
    %programfiles%\crypto pro\csp\bat_cpverify.bat 

    Исходники ГП - тут \\ilc-fileserv\IT\GPO\PCwithCSP
#>

# Назначаем переменные
$ConfigPath = '\\ilccredits\it\GPO\PCwithCSP'
$TaskName1 = "CPVerify"
$TaskName2 = "PC_Reboot"
$ConfigName1 = $TaskName1 + ".xml"
$ConfigName2 = $TaskName2 + ".xml"
$DirCSP = "C:\Program Files\Crypto Pro\CSP" 
$User = "ilccredits\admin"
$Pass = "P@rabola-2ilc"

# Проводим проверку наличия CSP на ПК 
$CSP = Get-ChildItem -Path $DirCSP 
$Serv = (Get-WmiObject -class Win32_OperatingSystem).Caption 
    if ($null -eq $CSP -or $Serv -like "*Server*" -or $Serv -like "*Сервер*") {
        $SwitchFlag = '1'
    }
    else {
        $SwitchFlag = '2'
    }

Switch ($SwitchFlag) {

# Выполняем проверку наличия таска и если его нет - тогда создаем
    2 {$FindTask1 = Get-ScheduledTask -TaskName $TaskName1 
        if ($null -eq $FindTask1) {
            Register-ScheduledTask -xml `
                (Get-Content $ConfigPath\$ConfigName1 | Out-String) -TaskName "$TaskName1" -TaskPath "\" -User $User -Password $Pass –Force
            }

        $FindTask2 = Get-ScheduledTask -TaskName $TaskName2 
            if ($null -eq $FindTask2) {
                Register-ScheduledTask -xml `
                    (Get-Content $ConfigPath\$ConfigName2 | Out-String) -TaskName "$TaskName2" -TaskPath "\" -User $User -Password $Pass –Force
            }
       }
    
    # А если вдруг - КСП исчез - тогда отключаем задания 
    1 {
        Disable-ScheduledTask -TaskName $TaskName1 -Confirm $false 
        Disable-ScheduledTask -TaskName $TaskName2 -Confirm $false
    }
}