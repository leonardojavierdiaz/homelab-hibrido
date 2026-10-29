# Chequeo de salud de Active Directory. Guarda el resultado en un archivo con fecha.

$Out = "C:\Reports\ad-health-$(Get-Date -Format yyyyMMdd-HHmm).txt"
New-Item -ItemType Directory -Path (Split-Path $Out) -Force | Out-Null

$Checks = [ordered]@{
  "dcdiag"                = { dcdiag }
  "dcdiag /test:dns"      = { dcdiag /test:dns }
  "netdom query fsmo"     = { netdom query fsmo }
  "w32tm /query /status"  = { w32tm /query /status }
  "repadmin /replsummary" = { repadmin /replsummary }
}

foreach ($name in $Checks.Keys) {
  "===== $name =====" | Out-File $Out -Append
  & $Checks[$name] 2>&1 | Out-File $Out -Append
}

Write-Host "Reporte guardado en $Out"
