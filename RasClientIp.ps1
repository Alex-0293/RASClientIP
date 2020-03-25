<#
    Name:       Список пользователей домена с указанием IP при удаленном доступе, праве удаленного доступа и состояния пароля
    Ver:           1.0
    Date:         25.10.2017
    Platform:  Windows server 2012
    PSVer:       4.0
    Author:     AlexK
#>


Clear-Host
Function DigitToStrIPAddress($Digit9IPAddress) { # Формируем IP адрес из числового представления 
    $bin = [convert]::ToString([int32]$Digit9IPAddress, 2).PadLeft(32, '0').ToCharArray()
    $A = [convert]::ToByte($bin[0..7] -join "", 2)
    $B = [convert]::ToByte($bin[8..15] -join "", 2)
    $C = [convert]::ToByte($bin[16..23] -join "", 2)
    $D = [convert]::ToByte($bin[24..31] -join "", 2)
    return $($A, $B, $C, $D -join ".")
} 

$output = @() # Обнуляем хэш массив
$ADUsers = get-aduser -filter * -Properties * | Where-Object { $_.msRASSavedFramedIPAddress -ne $null } #Выбираем всех пользователей с установленным RAS IP 
Foreach ($AdUser in $ADUsers) {
    $res = [pscustomobject]@{
        Sam             = $AdUser.SamAccountName
        RASIp           = DigitToStrIPAddress($AdUser.msRADIUSFramedIPAddress)
        DialIn          = $AdUser.msnpallowdialin
        PasswordExpired = $AdUser.PasswordExpired
        Enabled         = $AdUser.Enabled
    }

    $output += $res
}

$output | Sort-Object rasip | Where-Object { $_.enabled -eq $true } | Format-Table -AutoSize

#$output | Sort-Object sam | Where-Object { $_.enabled -eq $true } | Export-Csv d:\rasip.csv