$uri = "https://PROXMOX-GOES-HERE:8006/api2/json/access/ticket"
$username = 
$password =  # Ideally, this should be securely stored or prompted for

$body = @{
    username = $username
    password = $password
}

$response = Invoke-RestMethod -Uri $uri -Method Post -Body $body -ContentType "application/x-www-form-urlencoded" -SkipCertificateCheck