# PS-Proxmox
Manage Proxmox with powershell

Function "Invoke-ProxmoxApi.ps1" allows you to manage proxmox via API token.

I ran in to an issue with the header format while using the api token due to special charecters in combination with using invoke-restmdethod. This was resolved once I discovered "-SkipHeaderValidation" switch.

This method of auth will allow me to restructure the scipts and remove the connect.ps1 and the need for the powershell module 'Corsinvest.ProxmoxVE.Api'


Before using project run:

```powershell
.\Setup\Setup.ps1
```

This will allow you to setup .\env\nodes.json and .\env\secrets.json, along with creating requires folder structure.


```powershell
.\build\Create-LXC-template.ps1 -FQDNorIP $FQDNorIP -ConfigFile ansible-lxc-template
```