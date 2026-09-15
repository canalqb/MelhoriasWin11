<div align="center">

# ⚡ MelhoriasWin11

**Script 100% automático para remover bloatware, desativar telemetria e otimizar o Windows 10/11.**

Sem instalar nada · sem precisar saber programar · sem fazer nenhuma pergunta.

![Plataforma](https://img.shields.io/badge/Plataforma-Windows_10%20%7C%2011-blue?style=flat-square)
![PowerShell](https://img.shields.io/badge/Linguagem-PowerShell_5.1-5391FE?style=flat-square)
![Modo](https://img.shields.io/badge/Modo-Silencioso-brightgreen?style=flat-square)

</div>

---

## 📋 Resumo

Este pacote contém **apenas scripts de configuração**:

| Arquivo | Função |
|---------|--------|
| `MelhoriasWin11.ps1` | Motor da automação (PowerShell) |
| `ExecutarMelhorias.bat` | Atalho de 2 cliques que pede permissão de administrador |
| `README.md` | Este manual |

O motor usa o [Win11Debloat](https://github.com/Raphire/Win11Debloat) (57k+ ⭐) para debloat, e aplica camadas extras de otimização. **Tudo em silêncio, sem perguntas.**

---

## ✅ Requisitos

| Item | Necessário? |
|------|-------------|
| Sistema | Windows 10 ou Windows 11 (x64) |
| Permissão | Conta de administrador (aceitar o aviso UAC) |
| Internet | Apenas na **primeira** execução (baixa o motor Win11Debloat) |
| Espaço em disco | ~80 MB temporários |
| Conhecimento técnico | **Nenhum** |

---

## 🚀 Como usar — passo a passo

### Opção A — Via `ExecutarMelhorias.bat` (recomendado)

1. **Baixe a pasta completa** deste repositório clicando em **Code → Download ZIP** e extraia em qualquer lugar (Desktop, pasta própria, pendrive). Mantenha os arquivos `ExecutarMelhorias.bat` e `MelhoriasWin11.ps1` **na mesma pasta**.
2. **Desbloqueie os arquivos** (evita bloqueio do SmartScreen):
   - Clique direito no arquivo `MelhoriasWin11.ps1` → **Propriedades** → marque **Desbloquear** → **OK**.
   - Repita para o `ExecutarMelhorias.bat`.
3. **Clique com o botão direito** em `ExecutarMelhorias.bat` e escolha **“Executar como administrador”**.
   - Se aparecer o aviso do UAC, clique em **Sim**.
4. **Aguardar ≈ 3 minutos.** O terminal mostra o progresso em 5 etapas e o Explorer reinicia sozinho no final.
5. **Reinicie o PC** quando o script terminar, para garantir que 100% das mudanças sejam aplicadas.

### Opção B — Via PowerShell (sem o .bat)

Abra um **PowerShell como administrador** (botão direito no menu Iniciar → *Terminal (Admin)*) e execute:

```powershell
cd "C:\caminho\da\pasta"
powershell -ExecutionPolicy Bypass -File .\MelhoriasWin11.ps1
```

> Se o Windows alertar que os scripts estão bloqueados, execute antes: `Get-ChildItem .\MelhoriasWin11.ps1 | Unblock-File`

---

## ⚙️ O que o script faz (por etapa)

| Etapa | Ação |
|-------|------|
| 1. Download | Baixa o Win11Debloat pela 1ª vez (ou usa o cache) e **cria ponto de restauração** |
| 2. Debloat | Desativa telemetria, Copilot, Recall, anúncios, Bing e remove 84 apps de bloatware |
| 3. Extras | Tela nunca desliga, limpa autostart desnecessário, ajusta SysMain/Page Combining/efeitos visuais |
| 4. Limpeza | Apaga arquivos temporários (`%TEMP%`, `%WINDIR%\Temp`, INetCache) |
| 5. Final | Reinicia o Explorer para aplicar as mudanças |

### Detalhes do debloat (Win11Debloat)

| Área | O que desativa/remove |
|------|----------------------|
| **Privacidade** | Telemetria, sugestões, anúncios, Bing, localização, Find My Device, notificações |
| **IA** | Copilot, Recall, Click to Do, IA no Edge, AI service autostart |
| **Jogos** | Game Bar, DVR, GamingOverlay, apps de jogos |
| **Apps** | 84 apps de bloatware (Xbox, Clipchamp, Teams, Solitaire, TikTok, OneNote…). Reinstaláveis pela Microsoft Store |
| **Sistema** | Fast startup, Storage Sense, Delivery Optimization |
| **Menu Iniciar** | Recomendados ocultos, Phone Link desativado, Widgets removidos |
| **Barra de tarefas** | End Task, Last Active Click, Taskview/Chat ocultos |
| **Explorador** | Extensões visíveis, arquivos ocultos, “Este PC” como página inicial, menu clássico |

### Otimizações extras (exclusivas deste pacote)

| Ajuste | O que faz | Por quê |
|--------|-----------|---------|
| Tela nunca desliga | `powercfg /change ... 0` | Evita tela travando/trava de bloqueio |
| Autostart limpo | Remove entradas do registro e **atalhos** da pasta Startup | Sem apagar nenhum programa |
| SysMain/“Superfetch” | Manual via **registro** (Start=3) | Mais confiável que `Set-Service` (não reverte) |
| Page Combining | Desativado | Menos pressão de RAM em SSD + 16 GB |
| Efeitos visuais | “Melhor desempenho” (VisualFXSetting=2) | Mais fluidez em GPU integrada |

### 🔒 O que o script **NÃO** faz

- ❌ **Não apaga arquivos** nem pastas pessoais
- ❌ **Não desativa o TRIM do SSD** (diferente da maioria dos scripts — TRIM é obrigatório p/ SSD, é preservado)
- ❌ **Não desativa o Windows Defender**
- ❌ **Não toca no Edge** de sistema
- ❌ **Não instala software** de terceiros
- ❌ **Não coleta/não envia seus dados**
- ❌ **Não altera rede, Wi-Fi ou DNS**

---

## 🛠️ Opções — personalizar o que será aplicado

Tudo é controlado pelo array `$params` dentro do `MelhoriasWin11.ps1` (linha ~80). Edite com o Bloco de Notas e salve.

### Exemplo 1 — manutenção mínima (mais conservadora)

```powershell
$params = @(
    '-Silent'
    '-CreateRestorePoint'
    '-DisableTelemetry'
    '-DisableBing'
    '-DisableCopilot'
    # '-RemoveApps'          # ← descomente para remover os apps de bloatware
    # '-RemoveGamingApps'    # ← descomente para remover apps de jogos
)
```

### Parâmetros úteis mais comuns

| Parâmetro | Efeito |
|-----------|--------|
| `-RemoveApps` | Remove apps pré-instalados (Xbox, Teams, Clipchamp…) |
| `-RemoveGamingApps` | Remove apps de jogos (Game Bar, Solitaire…) |
| `-DisableTelemetry` | Desativa telemetria e dados de diagnóstico |
| `-DisableCopilot` / `-DisableRecall` | Desativa IA |
| `-DisableBing` | Remove Bing/busca web |
| `-DisableStartRecommended` | Esconde “Recomendados” do Menu Iniciar |
| `-DisableWidgets` | Remove Widgets |
| `-HideTaskview` / `-HideChat` | Limpa a barra de tarefas |
| `-DisableFastStartup` | Desativa inicialização rápida (evita travamentos) |

> Para comentar um parâmetro, adicione `#` no início da linha. Para reativar, remova o `#`.
> Lista completa de parâmetros: [Documentação CLI do Win11Debloat](https://github.com/Raphire/Win11Debloat/wiki/Command%E2%80%90line-Interface#parameters)

---

## 🩺 Solução de problemas

| Problema | Solução |
|----------|---------|
| **O .bat fecha na hora / “script bloqueado”** | Os arquivos vieram bloqueados do download. Clique direito → **Propriedades** → **Desbloquear** → OK, e rode de novo. |
| **Aviso de Execution Policy** | Os scripts já rodam com `-ExecutionPolicy Bypass`, mas isso também resolve: `Unblock-File -Path .\MelhoriasWin11.ps1`. |
| **UAC não aparece ou nega** | Você precisa de uma conta de administrador. Crie/use uma em Contas → Família e outros usuários. |
| **Erro no download do Win11Debloat (sem internet)** | Verifique a conexão ou rode num PC com internet na primeira vez. |
| **Quero rodar offline depois** | Mantenha a pasta `Win11DebloatCache` (ela guarda o motor). Se apagar, o script baixa de novo. |
| **Alguma alteração não foi aplicada** | Veja o arquivo `Log_MelhoriasWin11.txt` (criado na mesma pasta) e procure por `[ERRO]`/`[AVISO]`. |
| **O que esse log significa?** | Cada linha segue: `[data hora] [TIPO] mensagem`. `INFO` = sucesso, `AVISO` = ignorado, `ERRO` = falhou. |
| **Recovery/recuperação do sistema** | O script cria **ponto de restauração** antes de mudar tudo. Win + R → `sysdm.cpl` → Proteção do Sistema → Restauração. |

### 🔄 Como desfazer (reverter tudo)

1. **Restauração do Sistema** (mais completo, recomendado): `sysdm.cpl` → **Proteção do Sistema** → **Restauração do Sistema** → escolha o ponto criado pelo script → reinicie.
2. **Reinstalar apps removidos:** abra a **Microsoft Store** → pesquise (Clipart, Teams, Solitaire…) → **Instalar**.
3. **Reativar telemetria/IA:** reverso manual via Configurações → Privacidade e segurança, ou rode o Win11Debloat sem os `-Disable*` correspondentes.

---

## ❓ Perguntas frequentes

**Funciona no Windows 10?**
Sim. O Win11Debloat tem suporte oficial ao Windows 10 e 11.

**Meu PC usa SSD — é seguro?**
Sim. O script **preserva o TRIM**. Ele só ajusta SysMain e Page Combining, que não afetam a saúde do disco.

**Consome internet? Quanto?**
Só na primeira execução (± 80 MB do motor Win11Debloat). Depois fica em cache e roda offline.

**Posso usar em vários PCs?**
Sim. Copie a pasta para outros computadores e repita os passos. No 2º PC a internet é necessária na 1ª vez.

**Como sei que funcionou?**
O script gera `Log_MelhoriasWin11.txt` com todas as mudanças aplicadas.

**Posso escolher o que remover?**
Sim, editando o `$params` — veja [Opções](#-opções--personalizar-o-que-será-aplicado).

---

## 📁 Estrutura do repositório

```
MelhoriasWin11/
│
├─ README.md                ← Este manual
├─ ExecutarMelhorias.bat    ← Inicie por aqui (2 cliques)
└─ MelhoriasWin11.ps1       ← Motor da automação
```

*O `Win11DebloatCache/` e o `Log_MelhoriasWin11.txt` são gerados em tempo de execução na pasta local — não existem neste repositório.*

---

## 🙏 Créditos

| Componente | Crédito |
|------------|---------|
| Motor de debloat | [Win11Debloat](https://github.com/Raphire/Win11Debloat) — Raphire (57k+ ⭐) |
| Automação e ajustes extras | Este repositório |

---

> ⚠️ **Aviso:** Use por sua conta e risco. Faça um backup dos seus dados importantes antes de executar. O script cria ponto de restauração, mas não é garantia contra tudo.