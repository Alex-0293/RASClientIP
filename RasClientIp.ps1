<#
    Name:       Список пользователей домена с указанием IP при удаленном доступе, праве удаленного доступа и состояния пароля
    Ver:           1.0
    Date:         25.10.2017
    Platform:  Windows server 2012
    PSVer:       4.0
    Author:     AlexK
#>
$ImportResult = Import-Module AlexkUtils  -PassThru
if ($null -eq $ImportResult) {
    Write-Host "Module 'AlexkUtils' does not loaded!"
    exit 1
}
else {
    $ImportResult = $null
}
#requires -version 3

#########################################################################
function Get-WorkDir () {
    if ($PSScriptRoot -eq "") {
        if ($PWD -ne "") {
            $MyScriptRoot = $PWD
        }        
        else {
            Write-Host "Where i am? What is my work dir?"
        }
    }
    else {
        $MyScriptRoot = $PSScriptRoot
    }
    return $MyScriptRoot
}
# Error trap
trap {
    Get-ErrorReporting $_    
    exit 1
}
#########################################################################

Clear-Host

$MyScriptRoot = Get-Workdir

Get-VarsFromFile    "$MyScriptRoot\Vars.ps1"
Initialize-Logging $MyScriptRoot "Latest"

$User = Get-VarFromAESFile $Global:GlobalKey1 $Global:APP_SCRIPT_ADMIN_Login
$Pass = Get-VarFromAESFile $Global:GlobalKey1 $Global:APP_SCRIPT_ADMIN_Pass

$Credentials = New-Object System.Management.Automation.PSCredential -ArgumentList (Get-VarToString $User), $Pass

#$Global:PSSession1 = New-PSSession -ComputerName $Global:Computer  -Credential $Credentials 
[array]$output = @() 
$output = Invoke-Command -ComputerName  $Global:Computer  -Credential $Credentials  -ScriptBlock {`
        Function DigitToStrIPAddress($Digit9IPAddress) {
        # Формируем IP адрес из числового представления 
        $bin = [convert]::ToString([int32]$Digit9IPAddress, 2).PadLeft(32, '0').ToCharArray()
        $A = [convert]::ToByte($bin[0..7] -join "", 2)
        $B = [convert]::ToByte($bin[8..15] -join "", 2)
        $C = [convert]::ToByte($bin[16..23] -join "", 2)
        $D = [convert]::ToByte($bin[24..31] -join "", 2)
        return $($A, $B, $C, $D -join ".")
    } 
    Import-Module ActiveDirectory
    [array]$output = @()  # Инициализируем хэш массив
    $ADUsers = get-aduser -filter * -Properties * | Where-Object { $_.msRADIUSFramedIPAddress -ne $null } #Выбираем всех пользователей с установленным RAS IP 
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

    
    return $output | Sort-Object rasip | Where-Object { $_.enabled -eq $true } 
    #$output | Sort-Object sam | Where-Object { $_.enabled -eq $true } | Export-Csv d:\rasip.csv
} 

#$output.gettype()
$output | Select-Object Sam, RASIp, DialIn, PasswordExpired, Enabled | Format-Table -AutoSize