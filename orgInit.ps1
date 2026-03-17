# Включаем строгий режим (скрипт остановится, если что-то пойдет не так)
$ErrorActionPreference = 'Stop'
Write-Host "--- 🚀 STARTING SETUP ---" -ForegroundColor Green

# 1. Удаляем старую оргу (Хитрый способ без скобок)
Write-Host "1. Cleaning up old org..."
# Временно разрешаем ошибки (чтобы не падал, если орги нет)
$ErrorActionPreference = 'SilentlyContinue'
sf org delete scratch --target-org MyDevOrg --no-prompt
# Возвращаем строгий режим обратно
$ErrorActionPreference = 'Stop'

# 2. Создаем новую
Write-Host "2. Creating Scratch Org..."
sf org create scratch --definition-file config/project-scratch-def.json --alias MyDevOrg --duration-days 7 --set-default

# 3. Деплоим метаданные
Write-Host "3. Pushing Source..."
sf project deploy start

# 4. ЗАЛИВАЕМ ДАННЫЕ ЧЕРЕЗ APEX
if (Test-Path "scripts/apex/createData.apex") {
    Write-Host "4. Seeding Data via Apex..."
    sf apex run --file scripts/apex/createData.apex
} else {
    Write-Host "⚠️ Apex script not found!" -ForegroundColor Red
}

# 5. Создаем юзера (Опционально)
if (Test-Path "config/tester-user-def.json") {
    Write-Host "5. Creating User..."
    sf org create user --definition-file config/tester-user-def.json --set-alias MyTester
}

Write-Host "✅ DONE! Opening Org..." -ForegroundColor Green
sf org open