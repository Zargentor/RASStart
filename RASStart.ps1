[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
# Проверка на запуск от имени администратора
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    # Если нет, перезапускаем скрипт с правами администратора
    $newProcess = New-Object System.Diagnostics.ProcessStartInfo "powershell";
    $newProcess.Arguments = "& '" + $myInvocation.MyCommand.Definition + "'";
    $newProcess.Verb = "runas";
    [System.Diagnostics.Process]::Start($newProcess);
    exit;
}
$StartPort = "19"
# Определение переменных
$CtrlPort = "$($StartPort)40"
$AgentName = [System.Net.Dns]::GetHostByName($env:computerName) | Select-Object -ExpandProperty hostname
$RASPort = "$($StartPort)45"
$RASPath = """C:\Program Files\1cv8\8.3.24.1667\bin\ras.exe"""
$SrvcName = "1C:Enterprise 8.3 Remote Server $($StartPort)45"
$BinPath = "$RASPath cluster --service --port=$RASPort $AgentName`:$CtrlPort"
$Description = "1C:Enterprise 8.3 Remote Server $($StartPort)45 1C_Buh_TZK"

# Остановка и удаление существующей службы, если она существует
Stop-Service -Name $SrvcName -ErrorAction SilentlyContinue
sc.exe delete $SrvcName

# Создание новой службы
New-Service -Name $SrvcName -BinaryPathName $BinPath -DisplayName $Description -StartupType Automatic

# Запуск службы
Start-Service -Name $SrvcName
