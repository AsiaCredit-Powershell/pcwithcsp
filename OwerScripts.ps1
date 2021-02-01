# Настраиваем переменные для работы со скриптом 
$Path = "C:\temp"
$File = "$Path\cryptohave.txt" 
$FileError = "$Path\cryptohaveError.txt" 
$ErrorMessage = "Крипто про не найден"

# Получаем машины и циклом проверяем у них наличие  крипто про.
# Если крипто про есть - тогда имя ПК записывается в файл $File 
$Comps = Get-ADComputer -Filter 'name -like "*" ' -Properties *
$CompsName = $Comps | select -ExpandProperty name 
$CryptoHave = foreach ($CompName in $CompsName) {
   $64 = Get-ChildItem "\\$CompName\c$\Program Files\Crypto Pro\CSP\"  -Force -ErrorAction Ignore
        if ($null -eq $64) {
            $32 = Get-ChildItem "\\$CompName\c$\Program Files (x86)\Crypto Pro\CSP\"  -Force -ErrorAction Ignore
            $32 | Out-File -FilePath "$FileError" -Encoding utf8 -Append }
        else {
        $CompName | Out-File "$FileError" -Encoding utf8 -Append }
}

gc '\\ILC-NSB-CASH1\C$\Program Files\Crypto Pro\CSP\cpconfig.xml'

$CryptoHavePCs = Get-Content $File 
$CopyCPVerify  = foreach ($CryptoHavePC in $CryptoHavePCs){
    Copy-Item C:\temp\cpverify.exe "\\$CryptoHavePC\C$\Program Files (x86)\Crypto Pro\CSP"
    Copy-Item C:\temp\bat_cpverify.bat "\\$CryptoHavePC\C$\Program Files (x86)\Crypto Pro\CSP"
    $DesktopPath = [Environment]::GetFolderPath("Desktop")

    
}

# Настраиваем РДП для всех 
$CryptoHavePCs = Get-Content $File 
$EnabledRDP  = foreach ($CryptoHavePC in $CryptoHavePCs){
    Invoke-Command -ComputerName $CryptoHavePC -ScriptBlock { $env:COMPUTERNAME
    Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -name "fDenyTSConnections" -Value 0
    Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -name UserAuthentication -Value 0
    Enable-NetFirewallRule -DisplayGroup "Remote Desktop"
        New-NetFirewallRule -DisplayName 'allow RemoteDesktop' -Profile @('Domain', 'Private') -Direction Inbound -Action Allow -Protocol TCP -LocalPort @('3389')}
        }

# Выводим ярлык удаленного помошника 

$EnabledRDP  = foreach ($CryptoHavePC in $CryptoHavePCs){
    Limit-EventLog -LogName Application,Security,System,'Internet Explorer' -ComputerName $CryptoHavePC -MaximumSize 60MB -OverflowAction DoNotOverwrite
}





# отключаем службы удаленных подключений. 
$CryptoHavePCs = Get-Content $File 
$PO = foreach ($CryptoHavePC in $CryptoHavePCs) {
    Invoke-Command -ComputerName $CryptoHavePC -ScriptBlock {
     Set-Service -Name 'TeamViewer' -StartupType Disabled 
     Stop-Service -Name 'TeamViewer' -Force 
     get-Service -Name 'TeamViewer' 
     remove-item -path "c:\program files (x86)\teamviewer\" -force -recurse 
    }}
    Get-Service -ComputerName ILC-PVL-SKS2 | where {$_.name -like 'TeamViewer' -or $_.name -like 'winvnc' -or $_.name -like 'ScreenConnect*'}


    $PO = foreach ($CryptoHavePC in $CryptoHavePCs) {
        #Invoke-Command -ComputerName $CryptoHavePC -ScriptBlock {
            ls "\\ILC-SPS-CASH2\C$\Users\*\desktop\" -Filter "удален*" }

         $PO | select pscomputername | where {$_.pscomputername -like "*PVL*"} 
            
         }
         


$PCName = "ILC-EKB-CASH1"
        $PO = foreach ($CryptoHavePC in $CryptoHavePCs) {
        Invoke-Command -ComputerName $CryptoHavePC -ScriptBlock {
            Get-WinEvent -LogName Microsoft-Windows-GroupPolicy/Operational | Where-Object {$_.timecreated -gt '01/28/2021'}
         }}
         Copy-Item -Path \\$PCName\c$\gpresults.html -Destination C:\temp\gpresult_EKB.html
            
         $PO | select TimeCreated,message,task | sort TimeCreated -Descending | export-csv -Path c:\temp\GPO.csv -Encoding utf8 -Delimiter ";" 

         
                


    $GPUpdate = foreach ($CryptoHavePC in $CryptoHavePCs) {
        Invoke-Command -ComputerName $CryptoHavePC -ScriptBlock {
            gpupdate.exe /force
        }}


        # Подготавливаем переменные 
$Path = "C:\temp"
$FileLogs = "$Path\GPO.csv" 
$FileFilterLog = "$Path\filterGPO.csv"

# Получаем данные с журналов компов (так быстрее чем get-winevent -computername *)
$ReadingEvent = foreach ($CryptoHavePC in $CryptoHavePCs) {
        Invoke-Command -ComputerName $CryptoHavePC -ScriptBlock {
            Get-WinEvent -LogName Microsoft-Windows-GroupPolicy/Operational | Where-Object {$_.timecreated -gt '01/29/2021'}

         }}
# Фильтруем вывод на нужный нам и экспортируем в CSV (так легче просматривать (ИМХО))
$ReadingEvent | select TimeCreated,message,task,pscomputername | sort TimeCreated -Descending | export-csv -Path $FileLogs -Encoding utf8 -Delimiter ";" 

# Получаем данные с нужными заголовками 
$LogS = Import-Csv -Delimiter ";" -Path $FileLogs -Header time,message,task 

# Фильтруем данные по заголовкам, дабы смотреть только то, что нам требуется 
$FilterLogs = $LogS | where {$_.message -like "*PCwithCSP*"}
$FilterLogs | sort time -Descending | export-csv -Path $FileFilterLog -Encoding UTF8 -Delimiter ";"



# запос gpresult с машин для отладки 
$pathGPOReport = "C:\temp\CSP_GPO"
foreach ($CryptoHavePC in $CryptoHavePCs) {
    Invoke-Command -ComputerName $CryptoHavePC -ScriptBlock {
        Remove-Item -Path "\\$CryptoHavePC\C$\Users\Public\Desktop\*.html"
        $NameReport = $env:COMPUTERNAME + "gpo_CSP.html"
        gpresult.exe /h "C:\users\Public\Desktop\$NameReport"
        }
    
    Copy-Item -Path "\\$CryptoHavePC\C$\Users\Public\Desktop\*.html" -Destination "$pathGPOReport\"
    }

    $DebugMachine = "ILC-FTK-CASH1"
    
   $TestMashine = invoke-Command -ComputerName ILC-FTK-CASH1 -ScriptBlock {
            Get-WinEvent -LogName Microsoft-Windows-GroupPolicy/Operational | Where-Object {$_.timecreated -gt '01/29/2021'}}
            $TestMashine | select TimeCreated,message,task | sort TimeCreated -Descending | export-csv -Path $Path\ILC-FTK-CASH1.csv -Encoding utf8 -Delimiter ";" 

# gpupdate для отладки
$app = foreach ($CryptoHavePC in $CryptoHavePCs) {
    Invoke-Command -ComputerName $CryptoHavePC -ScriptBlock {
         gci -Path "C:\Program Files\" -Filter "screencon*"
         gci -Path "C:\Program Files (x86)\" -Filter 'screencon*' 
    }}



# запос gpresult с машин для отладки
$DebugMachine = "ILC-FTK-CASH1" 
$pathGPOReport = "C:\temp\CSP_GPO"
#foreach ($CryptoHavePC in $CryptoHavePCs) {
    Invoke-Command -ComputerName $DebugMachine -ScriptBlock {
        $NameReport = $env:COMPUTERNAME + "gpo_CSP.html"
        gpresult.exe /h "C:\users\Public\Desktop\$NameReport"
        }

    Copy-Item -Path "\\$CryptoHavePC\C$\Users\Public\Desktop\*.html" -Destination "$pathGPOReport\"
    #}





    $Comps = Get-ADComputer -Filter 'name -like "*" ' -Properties *
        $CompsName = $Comps | select -ExpandProperty name 
        $CryptoHave = foreach ($CompName in $CompsName) {
            $64 = Get-ChildItem "\\$CompName\c$\Program Files\Crypto Pro\CSP\" -Filter "certmgr.exe" -Force -ErrorAction Ignore
            }

New-Item -Path \\ilc-fileserv\it\GPO\PCwithCSP -ItemType directory -name GPOBackup
Backup-GPO -Name PCwithCSP -Path \\ilc-fileserv\it\GPO\PCwithCSP\GPOBackup\