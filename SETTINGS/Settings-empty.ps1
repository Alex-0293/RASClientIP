# Rename this file to Settings.ps1
#### Script params 
    [String]$Global:APP_SCRIPT_ADMIN_Login = ""          # AES Login Value.
    [String]$Global:APP_SCRIPT_ADMIN_Pass  = ""          # AES Password Value.
    [String]$Global:Computer               = ""          # Domain controller name.

[bool] $Global:LocalSettingsSuccessfullyLoaded = ""          

# Error trap
trap {
    $Global:LocalSettingsSuccessfullyLoaded = ""          
    exit 1
}
