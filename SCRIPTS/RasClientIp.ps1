<#
    .SYNOPSIS 
        .AUTOR
        .DATE
        .VER
    .DESCRIPTION
    .PARAMETER
    .EXAMPLE
#>
Clear-Host
$Global:ScriptName = $MyInvocation.MyCommand.Name
$InitScript = "C:\DATA\Projects\GlobalSettings\SCRIPTS\Init.ps1"
if (. "$InitScript" -MyScriptRoot (Split-Path $PSCommandPath -Parent)) { exit 1 }
# Error trap
trap {
    if ($Global:Logger) {
       Get-ErrorReporting $_
        . "$GlobalSettings\$SCRIPTSFolder\Finish.ps1"  
    }
    Else {
        Write-Host "There is error before logging initialized." -ForegroundColor Red
    }   
    exit 1
}
################################# Script start here #################################

$User = Get-VarFromAESFile $Global:GlobalKey1 $Global:APP_SCRIPT_ADMIN_Login
$Pass = Get-VarFromAESFile $Global:GlobalKey1 $Global:APP_SCRIPT_ADMIN_Pass

$Credentials = New-Object System.Management.Automation.PSCredential -ArgumentList (Get-VarToString $User), $Pass

#$Global:PSSession1 = New-PSSession -ComputerName $Global:Computer  -Credential $Credentials 
[array]$output = @() 
$output = Invoke-Command -ComputerName  $Global:Computer  -Credential $Credentials  -ScriptBlock {`
    Function DigitToStrIPAddress($Digit9IPAddress) {
        $bin = [convert]::ToString([int32]$Digit9IPAddress, 2).PadLeft(32, '0').ToCharArray()
        $A = [convert]::ToByte($bin[0..7] -join "", 2)
        $B = [convert]::ToByte($bin[8..15] -join "", 2)
        $C = [convert]::ToByte($bin[16..23] -join "", 2)
        $D = [convert]::ToByte($bin[24..31] -join "", 2)
        return $($A, $B, $C, $D -join ".")
    } 
    Import-Module ActiveDirectory
    [array]$output = @()
    $ADUsers = get-aduser -filter * -Properties * | Where-Object { $_.msRADIUSFramedIPAddress -ne $null }
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

################################# Script end here ###################################
. "$GlobalSettings\$SCRIPTSFolder\Finish.ps1"