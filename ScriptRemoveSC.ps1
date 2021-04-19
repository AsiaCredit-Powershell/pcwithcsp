<#
    Скрипт необходимый для удаления СК. 
    Работает так: ищется по пути C:\Program Files (x86)\ каталог с наименованием 'screencon*'
    Если он находится, то останавливаем службы, переводим в ручной запуск и удаляем каталог.
    Если не находится - пишем в лог данные LogPath
    
    Это связано с требованиями ЦБ, дабы на компах, использующихся с крипто про - не было утилит для удаленного доступа
    глядящих в интернет. 
#>

# Настройка переменных 
$ServiceName = Get-Service -Name *screenco*
$DirCSP = "C:\Program Files\Crypto Pro\CSP" 
$RemoveDir = "C:\Program Files\Crypto Pro"
$LogPath = "C:\remoteSC.txt"
$DelAppName = "ScreenConnect"
(Get-Date -Format "dd-MM-yyyy HH:mm:ss") + "Инициализация файла лога " | Out-File $LogPath -Encoding utf8 

# привязка фалогов на свитч (так легче отслеживать для дебага, нежели if\else 
$CSP = Get-ChildItem -Path $DirCSP 
    
# $CSP.count больше 3 файлов
# Ставим флаг 1  (на отключение \ удаление скринконнекта)
if ($CSP.count -gt 3) 
{
    $SwitchFlag = '1'
    $MessageFlag = "Был применен флаг № $SwitchFlag для удаления Скринконнекта"
}

# Если $CSP.count равно 2 файла
# Тогда удаляем $RemoveDir
elseif ($CSP.count -eq 2) 
{
    $SwitchFlag = '3'
    $MessageFlag = "Был применен флаг № $SwitchFlag для удаления лишней папки CSP и перевода Скринконнекта в атоматический запуск"
}

# Если сравнение не проходит не в первом, ни во втором шаге 
# Ничего не делаем. 
else 
{
    $SwitchFlag = '2'
    $MessageFlag = "Был применен флаг № $SwitchFlag который ничего не делает"
}


# Если Флаг равен 3 = тогда удаляем RemoveDir и включаем скринконнект. 
# А если 1 проверяем наличие папки SC и есть служба - удаляем службу
# А если папка и служба - есть, тогда стопаем службу и переводим в ручной режим
Switch ($SwitchFlag) {
    3 {
        Remove-Item -Path $RemoveDir -Recurse -Force
        Set-Service -Name $ServiceName.name -StartupType Automatic 
        Start-Service -Name $ServiceName.Name -Force
        $GetService = Get-Service $ServiceName | select *
        $GetCSP = Get-ChildItem -Path $RemoveDir 
        $MessageFlag = $MessageFlag + "`r`n" + "Данные сервиса " + "`r`n" + $GetService
    }
      
    1 { 
        Set-Service -Name $ServiceName.name -StartupType Manual 
        Stop-Service -Name $ServiceName.Name -Force
        $GetFilterProgramm = Get-WmiObject -Class Win32_Product -Filter "name -like '*$DelAppName*'"
        $AppNames = $GetFilterProgramm.name 
        
        # Если нет объекта - тогда выводим сообщение 
        if ($null -eq $GetFilterProgramm) 
        {
            $Message = $AppNames + "удален или не обнаружен "
        }
    
        # Если объект есть - тогда удаляем
        else 
        {
            "Произвожу удаление на машине " + $env:COMPUTERNAME
            foreach ($AppName in $AppNames) 
            {
                $GetFilterProgramm.uninstall()
            }
    
            $GetFilterProgrammVerify = Get-WmiObject -Class Win32_Product -Filter "name -like '*$DelAppName*'"
            $AppNames = $GetFilterProgrammVerify.name 
            
            # Осуществляем проверку удаления 
            if ($null -eq $GetFilterProgramm) 
            {
                $Message = $AppNames + "удален "
            }
            
            else 
            {
                $Message = $AppNames + " - удалить его не вышло"
            }
        } 
                    
        # Заполняем массив для дальнейшего удобства работы 
        $Array = [pscustomobject]@{Time = (Get-Date -Format "dd-MM-yyyy HH:mm:ss");ComputerName = "$env:COMPUTERNAME";Message = "$Message"}
        $Array | Out-File -FilePath $LogPath -Encoding utf8 -Append     
    }
}
    
    # Сама выборка. Если переменная = 2, тогда удаляем приложение. Пишем $MessageFlag в LogPath
$MessageFlag `
    | Out-File -FilePath $LogPath -Encoding utf8 -Append       