# Function to extract IP address
function Extract-IP {
    param (
        [string]$netConfig
    )
    $components = $netConfig.Split(",")
    $ipComponent = $components | Where-Object { $_ -like "ip=*" }

    if ($ipComponent) {
        return (($ipComponent -split "=")[1] -split "/")[0]
    } else {
        throw "IP component not found in the input string."
    }
}