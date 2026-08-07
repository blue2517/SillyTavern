@echo off
pushd %~dp0
set NODE_ENV=production
set NODE_OPTIONS=--preserve-symlinks
if not exist "node_modules\" (
  echo node_modules missing, running npm install...
  call npm install --no-save --no-audit --no-fund --loglevel=error --no-progress --omit=dev --ignore-scripts
)
node server.js %*
pause
popd
