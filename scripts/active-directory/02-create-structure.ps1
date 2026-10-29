# Crea la estructura base del dominio: OU, grupo y usuarios de prueba.
# Ajustá los nombres a tu caso antes de ejecutarlo.

Import-Module ActiveDirectory

$DomainDN = (Get-ADDomain).DistinguishedName
$BaseOU   = "OU=Lab,$DomainDN"

# OU protegidas contra borrado accidental
New-ADOrganizationalUnit -Name "Lab"        -Path $DomainDN -ProtectedFromAccidentalDeletion $true
New-ADOrganizationalUnit -Name "Usuarios"   -Path $BaseOU   -ProtectedFromAccidentalDeletion $true
New-ADOrganizationalUnit -Name "Grupos"     -Path $BaseOU   -ProtectedFromAccidentalDeletion $true
New-ADOrganizationalUnit -Name "Servidores" -Path $BaseOU   -ProtectedFromAccidentalDeletion $true

# Grupo de seguridad
New-ADGroup -Name "GG-Infraestructura" -GroupScope Global -GroupCategory Security `
  -Path "OU=Grupos,$BaseOU"

# Usuarios de prueba (la contraseña inicial se pide una sola vez)
$Password = Read-Host -AsSecureString "Contraseña inicial de los usuarios"

foreach ($u in @("usuario1", "usuario2")) {
  New-ADUser -Name $u -SamAccountName $u -UserPrincipalName "$u@$((Get-ADDomain).DNSRoot)" `
    -Path "OU=Usuarios,$BaseOU" -AccountPassword $Password -Enabled $true `
    -ChangePasswordAtLogon $true
  Add-ADGroupMember -Identity "GG-Infraestructura" -Members $u
}

# Papelera de reciclaje de AD: permite recuperar objetos borrados con Restore-ADObject
Enable-ADOptionalFeature -Identity "Recycle Bin Feature" -Scope ForestOrConfigurationSet `
  -Target (Get-ADDomain).DNSRoot -Confirm:$false
