function Get-LogRemove {
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
        $LogPath = "c$\remoteSC.txt"
        $FullPath = "\\$Name" + "\" + $LogPath
        $SearchPath = Get-ChildItem -Path $FullPath 
    
        # Если он есть - тогда берем его значение
        if ($null -ne $SearchPath) {
            $Text = Get-Content $FullPath 
        
            # Складываем данные в массив с именем ПК и текстом файла. Возвращаем значение в переменную Data
            $Data = [pscustomobject]@{ComputerName = "$name"; Text = "$Text"}
            $Data 
                }
            }
        
    else {
        $LogPath = "c$\remoteSC.txt"
        $FullPath = "\\$Name" + "\" + $LogPath
        $SearchPath = Get-ChildItem -Path $FullPath 
    
        # Если он есть - тогда берем его значение
        if ($null -ne $SearchPath) {
            $Text = Get-Content $FullPath 
        
            # Складываем данные в массив с именем ПК и текстом файла. Возвращаем значение в переменную Data
            $DataArray = [pscustomobject]@{ComputerName = "$name"; Text = "$Text"}
            $DataArray 
                }
            }       
        }
    return $DataArray
    }