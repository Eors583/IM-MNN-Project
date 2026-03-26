Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Write-Host "[*] 初始化/更新 submodules（recursive）"
git submodule sync --recursive
git submodule update --init --recursive

Write-Host "`n[*] Submodule 状态："
git submodule status --recursive

Write-Host "`n[*] 完成。接下来："
Write-Host "    - Android: 进入 apps/android 按其 README 运行"
Write-Host "    - iOS:     进入 apps/ios 按其 README 运行"

