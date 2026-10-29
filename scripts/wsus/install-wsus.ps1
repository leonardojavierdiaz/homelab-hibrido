# Instala WSUS con base interna (WID), configura el directorio de contenido
# y crea los grupos de equipos para el despliegue por anillos.

$ContentDir = "C:\WSUS"

Install-WindowsFeature -Name UpdateServices -IncludeManagementTools
New-Item -ItemType Directory -Path $ContentDir -Force | Out-Null
& "C:\Program Files\Update Services\Tools\wsusutil.exe" postinstall CONTENT_DIR=$ContentDir

$Wsus = Get-WsusServer

# Grupos para client-side targeting (los nombres deben coincidir con la GPO)
foreach ($g in @("Piloto", "Produccion")) {
  if (-not ($Wsus.GetComputerTargetGroups() | Where-Object Name -eq $g)) {
    $Wsus.CreateComputerTargetGroup($g) | Out-Null
  }
}

# El cliente usa los grupos definidos por GPO, no la asignación manual
$Config = $Wsus.GetConfiguration()
$Config.TargetingMode = "Client"
$Config.Save()

# Productos y clasificaciones: lo elegí desde la consola.
# Para Windows Server 2025: "Microsoft Server Operating System-24H2".
Write-Host "WSUS instalado. Elegí productos y clasificaciones y sincronizá desde la consola."
