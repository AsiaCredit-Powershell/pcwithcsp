<#
    Создаем задание на архивацию журнала по "забитию". У нас настроены журналы на 68 МБ без перезаписи:
        C:\Windows\System32\winevt\Logs\Application.evtx
	    C:\Windows\System32\winevt\Logs\Security.evtx
	    C:\Windows\System32\winevt\Logs\System.evtx
#>

# Настраиваем переменные:
$EventSecurity = "Security"
$EventSystem = "System"
$EventApplication = "Application"
$Date = (get-date -Format dd_MM_yyyy)
$ArchivePath = "C:\WinEventArch"
$NameDir = "WinEventArch"
$EventPath = "C:\Windows\System32\winevt\Logs\"

# Создаем каталог, если его нет 
$HavePath = Get-ChildItem -Path $ArchivePath 
    if ($null -eq $HavePath) {
        New-Item -Path c:\ -ItemType directory -name $NameDir 
    }

# Получаем значения объектов (файлов) для дальнейшего сравнения.
$AllEvent = Get-ChildItem -Path $EventPath -Filter "*"
$InfoEvent = $AllEvent | Where-Object {$_.Name -like "$EventSecurity.*" -or $_.Name -like "$EventSystem.*" -or $_.Name -like "$EventApplication.*"}
$SizeEvents = $InfoEvent | select name,length 

# В цикле выполняем проверку, если вес журнала больше 60МБ - тогда бэкапим и удаляем исходник. 
$SizeEvents | ForEach-Object -Process {
    if ($PSItem.Length -gt "60MB") {
        $Event = $PSItem.name -replace '.evtx',''
        $ArchiveName = $event + "-" + "$Date" + "-" + $env:computername
        $Eventlog = gwmi Win32_NTEventlogFile -Filter "LogFileName = '$Event'"
        $EventLog.PSBase.Scope.Options.EnablePrivileges = $true
        $Eventlog.BackupEventLog("$ArchivePath\$ArchiveName.evtx")
        $Eventlog.ClearEventlog($Event)
    }}
   