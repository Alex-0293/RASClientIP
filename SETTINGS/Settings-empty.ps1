# Rename this file to Settings.ps1
######################### value replacement #####################
    [String]$Global:APP_SCRIPT_ADMIN_Login = ""          # AES Login Value.
    [String]$Global:APP_SCRIPT_ADMIN_Pass  = ""          # AES Password Value.
    [String]$Global:Computer               = ""          # Domain controller name.

######################### no replacement ########################   

[bool] $Global:LocalSettingsSuccessfullyLoaded = $true          

# Error trap
trap {
    $Global:LocalSettingsSuccessfullyLoaded = $False          
    exit 1
}
