@echo off
chcp 65001 >nul
cd /d "%~dp0"
title Dream Experience - servidor local

echo.
echo  ===========================================
echo   Dream Experience - abrindo o site
echo  ===========================================
echo.
echo  Abrir o index.html direto (duplo clique no arquivo) nao funciona:
echo  o YouTube recusa o player e os videos nao tocam.
echo  Este atalho sobe um servidor local e abre no navegador.
echo.

start "Dream Experience - servidor (nao feche)" /min cmd /c "npx --yes http-server -p 8899 -s --cors -c-1"

echo  Subindo servidor...
powershell -NoProfile -Command "$u='http://127.0.0.1:8899/index.html'; for($i=0;$i -lt 40;$i++){ try{ if((Invoke-WebRequest $u -UseBasicParsing -TimeoutSec 2).StatusCode -eq 200){ exit 0 } }catch{}; Start-Sleep -Milliseconds 500 }; exit 1"

if errorlevel 1 (
  echo.
  echo  Nao consegui subir o servidor na porta 8899.
  echo  A porta pode estar ocupada, ou o Node.js nao esta instalado.
  echo.
  pause
  exit /b 1
)

start "" "http://localhost:8899/index.html"

echo.
echo  Pronto: http://localhost:8899
echo.
echo  Deixe a janela minimizada "Dream Experience - servidor" aberta
echo  enquanto estiver vendo o site. Para encerrar, feche aquela janela.
echo.
pause
