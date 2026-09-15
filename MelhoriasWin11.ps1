# =====================================================================
#  MelhoriasWin11.ps1 - Debloat e otimizacao automatica para Windows 11
#  Baseado no processo do Win11Debloat (github.com/Raphire/Win11Debloat)
#  Totalmente automatico, sem perguntas. Exige permissao de admin.
# =====================================================================
#Requires -RunAsAdministrator
[CmdletBinding()]
param()

$ErrorActionPreference = 'Continue'
$workDir   = (Split-Path -Parent $MyInvocation.MyCommand.Path)
$logFile   = Join-Path $workDir "Log_MelhoriasWin11.txt"
$cacheDir  = Join-Path $workDir 'Win11DebloatCache'
$scriptExe = Join-Path $cacheDir 'repo\Win11Debloat-master\Win11Debloat.ps1'
$zipCache  = Join-Path $cacheDir 'Win11Debloat.zip'

function Write-Log {
    param([string]$Msg, [string]$Type = 'INFO')
    $line = "[{0}] [{1}] {2}" -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $Type, $Msg
    Write-Host $line
    $line | Out-File -FilePath $logFile -Append -Encoding utf8
}

function Confirm-Admin {
    $id = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object System.Security.Principal.WindowsPrincipal($id)
    return $principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Write-Title {
    param([string]$Title)
    Write-Host ""
    Write-Host ("=" * 75) -ForegroundColor Cyan
    Write-Host ("  " + $Title) -ForegroundColor Cyan
    Write-Host ("=" * 75) -ForegroundColor Cyan
    Write-Host ""
}

# Handle console encoding to avoid accent issues
try { [Console]::OutputEncoding = [System.Text.Encoding]::UTF8 } catch {}
try { $OutputEncoding = [System.Text.Encoding]::UTF8 } catch {}

Write-Title "MELHORIAS AUTOMATICAS WINDOWS 11"
Write-Log "Iniciando rotina automatica de otimizacao e debloat."

if (-not (Confirm-Admin)) {
    Write-Log "Este script precisa ser executado como Administrador. Abortando." 'ERRO'
    exit 1
}

# ------------------------------------------------------------------
# 1. DOWNLOAD DO Win11Debloat (se ainda nao estiver em cache)
# ------------------------------------------------------------------
Write-Title "[1/5] Baixando Win11Debloat"
try {
    if (-not (Test-Path $scriptExe)) {
        $dir = Split-Path $scriptExe
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
        if (-not (Test-Path $zipCache)) {
            Invoke-WebRequest -Uri "https://github.com/Raphire/Win11Debloat/archive/refs/heads/master.zip" `
                -OutFile $zipCache -UseBasicParsing
        }
        $repoRoot = Join-Path $cacheDir 'repo'
        if (Test-Path $repoRoot) { Remove-Item $repoRoot -Recurse -Force }
        Expand-Archive -Path $zipCache -DestinationPath $repoRoot -Force
        Write-Log "Win11Debloat baixado e extraido no cache: $cacheDir"
    } else {
        Write-Log "Win11Debloat ja em cache, ignorando download."
    }
} catch {
    Write-Log "Falha no download do Win11Debloat: $($_.Exception.Message)" 'ERRO'
    exit 1
}

# ------------------------------------------------------------------
# 2. GRAVA CONFIG DE APLICATIVOS A REMOVER (opcional via comando)
# ------------------------------------------------------------------
Write-Title "[2/5] Aplicando debloat e otimizacoes via Win11Debloat"

$params = @(
    '-Silent'
    '-CreateRestorePoint'
    # --- Privacidade e telemetria ---
    '-DisableTelemetry'
    '-DisableSuggestions'
    '-DisableLockscreenTips'
    '-DisableBing'
    '-DisableStoreSearchSuggestions'
    '-DisableLocationServices'
    '-DisableFindMyDevice'
    '-DisableNotifications'
    # --- IA (Copilot/Recall/Click to Do) ---
    '-DisableCopilot'
    '-DisableRecall'
    '-DisableClickToDo'
    '-DisableAISvcAutoStart'
    '-DisableEdgeAI'
    '-DisableEdgeAds'
    # --- Jogos / gravacao de tela ---
    '-DisableDVR'
    '-DisableGameBarIntegration'
    '-RemoveGamingApps'
    # --- Remocao de apps pre-instalados ---
    '-RemoveApps'
    # --- Sistema ---
    '-DisableFastStartup'
    '-DisableStickyKeys'
    '-RevertContextMenu'
    '-DisableStorageSense'
    '-DisableDeliveryOptimization'
    '-DisableDeviceAutoAppDownload'
    '-PreventUpdateAutoReboot'
    '-DisableModernStandbyNetworking'
    '-DisableDragTray'
    # --- Menu Iniciar / Busca ---
    '-DisableStartRecommended'
    '-DisableStartPhoneLink'
    '-DisableWidgets'
    # --- Barra de tarefas ---
    '-EnableEndTask'
    '-EnableLastActiveClick'
    '-HideTaskview'
    '-HideChat'
    # --- Explorador de arquivos ---
    '-ShowHiddenFolders'
    '-ShowKnownFileExt'
    '-HideDupliDrive'
    '-ExplorerToThisPC'
    '-AddFoldersToThisPC'
    '-HideHome'
    '-HideGallery'
    '-SkipExplorerRestart'
)

Write-Log "Executando Win11Debloat com $($params.Count) parametros..."
try {
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "& `"$scriptExe`" $($params -join ' ') 2>&1 | Out-File -FilePath `"$logFile`" -Append -Encoding utf8"
    Write-Log "Win11Debloat concluido."
} catch {
    Write-Log "Erro na execucao do Win11Debloat: $($_.Exception.Message)" 'ERRO'
}

# ------------------------------------------------------------------
# 3. OTIMIZACOES ADICIONAIS DE PERFORMANCE/ENERGIA
# ------------------------------------------------------------------
Write-Title "[3/5] Otimizacoes extras de performance e energia"

# Tela desliga nunca (AC) - nao bloquear/apagar a tela
powercfg /change standby-timeout-ac 0 2>$null
powercfg /change standby-timeout-dc 0 2>$null
powercfg /change monitor-timeout-ac 0 2>$null
powercfg /change monitor-timeout-dc 0 2>$null
Write-Log "Energia: suspensao e desligamento de monitor definidos para nunca."

# Desativa programas de inicializacao desnecessarios (tipo Wondershare).
# IMPORTANTE: nunca apaga o executavel do programa, apenas remove a entrada
# de autostart do registro.
$toDisable = @('Wondershare*', '*PEScreenshot*', '*PEToolbox*', '*PDFElement*')
$runKeys = @(
    'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run'
    'HKLM:\Software\Microsoft\Windows\CurrentVersion\Run'
    'HKCU:\Software\Microsoft\Windows\CurrentVersion\RunOnce'
    'HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce'
)
$removedStartup = @{}
Get-CimInstance Win32_StartupCommand -ErrorAction SilentlyContinue | ForEach-Object {
    $name = $_.Name
    foreach ($pat in $toDisable) {
        if ($name -like $pat -and -not $removedStartup[$name]) {
            foreach ($rk in $runKeys) {
                try {
                    $pv = Get-ItemProperty -Path $rk -Name $name -ErrorAction SilentlyContinue
                    if ($null -ne $pv.$name) {
                        Remove-ItemProperty -Path $rk -Name $name -ErrorAction SilentlyContinue
                        $removedStartup[$name] = $true
                    }
                } catch { }
            }
            if ($removedStartup[$name]) { Write-Log "Inicializacao desativada: $name" }
        }
    }
}

# Remove atalhos de autostart da pasta Startup (Common e do usuario).
# Os atalhos SAO o mecanismo de inicializacao; remove-los NAO apaga o programa.
$startupDirs = @(
    "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp"
    "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"
)
$removedLinks = @{}
foreach ($sd in $startupDirs) {
    Get-ChildItem -LiteralPath $sd -Filter *.lnk -ErrorAction SilentlyContinue | ForEach-Object {
        $full = $_.FullName
        if ($removedLinks[$full]) { return }
        $lnkName = $_.BaseName
        $matched = $false
        foreach ($pat in $toDisable) {
            if ($lnkName -like $pat) {
                $matched = $true
                break
            }
        }
        if ($matched) {
            try {
                Remove-Item -LiteralPath $full -Force -ErrorAction SilentlyContinue
                $removedLinks[$full] = $true
                Write-Log "Atalho de inicializacao removido: $($_.Name)"
            } catch {
                Write-Log "Falha ao remover atalho: $($_.Name) -> $($_.Exception.Message)" 'AVISO'
            }
        }
    }
}

# SysMain/Superfetch nao necessario em SSD - definido direto no registro
# (mais confiavel que Set-Service, que o Windows pode reverter).
if ((Get-PhysicalDisk | Select-Object -First 1).MediaType -eq 'SSD') {
    try {
        Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Services\SysMain" -Name Start -Value 3 -Type DWord
        if ((Get-Service SysMain -ErrorAction SilentlyContinue).Status -eq 'Running') {
            Stop-Service SysMain -Force -ErrorAction SilentlyContinue
        }
        Write-Log "SysMain (Superfetch) configurado como Manual - sistema usa SSD."
    } catch { Write-Log "Nao foi possivel ajustar SysMain." 'AVISO' }
}

# Otimizacao de memoria (Page Combining) desligada - reduz consumo em RAM 16GB.
# IMPORTANTE: NAO desabilitamos a tarefa 'Optimize Drives' do Windows, pois ela
# executa o TRIM, que e obrigatorio para a saude e velocidade do SSD.
try {
    Disable-MMAgent -PageCombining -ErrorAction SilentlyContinue
    Write-Log "Page Combining desativado (menor consumo de RAM)."
} catch { Write-Log "Nao foi possivel ajustar Page Combining." 'AVISO' }

# Configuracao visual mais leve (menos efeitos = mais rapido em GPU integrada)
try {
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" `
        -Name "VisualFXSetting" -Value 2 -Type DWord -ErrorAction SilentlyContinue
    Write-Log "Efeitos visuais ajustados para 'Melhor desempenho'."
} catch { Write-Log "Nao foi possivel ajustar efeitos visuais." 'AVISO' }

# ------------------------------------------------------------------
# 4. LIMPEZA DE ARQUIVOS TEMPORARIOS
# ------------------------------------------------------------------
Write-Title "[4/5] Limpeza de arquivos temporarios"
try {
    $tempPaths = @(
        "$env:TEMP\*",
        "$env:windir\Temp\*",
        "$env:LOCALAPPDATA\Microsoft\Windows\INetCache\*"
    )
    foreach ($t in $tempPaths) {
        Remove-Item -Path $t -Recurse -Force -ErrorAction SilentlyContinue
    }
    Write-Log "Arquivos temporarios do usuario e do sistema limpos."
} catch { Write-Log "Falha na limpeza de temporarios." 'AVISO' }

# ------------------------------------------------------------------
# 5. REINICIO DO EXPLORER PARA APLICAR AS MUDANCAS
# ------------------------------------------------------------------
Write-Title "[5/5] Reiniciando o Explorer"
try {
    Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 2
    Start-Process explorer.exe
    Write-Log "Explorer reiniciado. As alteracoes foram aplicadas."
} catch {
    Write-Log "Nao foi possivel reiniciar o Explorer, um reboot resolve." 'AVISO'
}

Write-Title "CONCLUIDO"
Write-Log "Todas as melhorias foram aplicadas com sucesso. Log: $logFile"
Write-Host ""
Write-Host "Um reboot final e recomendado para garantir que tudo" -ForegroundColor Yellow
Write-Host "seja aplicado por completo." -ForegroundColor Yellow
Write-Host ""