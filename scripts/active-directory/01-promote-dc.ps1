# Promueve el servidor a controlador de dominio de un bosque nuevo.
# Equivalente en PowerShell de lo que hice desde Server Manager.
# Ejecutar como administrador. El servidor se reinicia al final.

$DomainName  = "lab.local"
$NetbiosName = "LAB"

Install-WindowsFeature AD-Domain-Services -IncludeManagementTools

# La contraseña de modo de restauración (DSRM) se pide en el momento.
$Dsrm = Read-Host -AsSecureString "Contraseña DSRM"

Install-ADDSForest `
  -DomainName $DomainName `
  -DomainNetbiosName $NetbiosName `
  -InstallDns `
  -SafeModeAdministratorPassword $Dsrm `
  -Force

# Después del reinicio, configurar el reenviador al DNS de Azure:
#   Add-DnsServerForwarder -IPAddress 168.63.129.16
