@echo off
echo ========================================
echo   Creando Ejecutable de la Aplicacion
echo ========================================
echo.

REM Verificar si Python esta instalado
python --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Python no esta instalado o no esta en el PATH
    echo Por favor instala Python desde https://www.python.org/downloads/
    pause
    exit /b 1
)

echo [1/3] Instalando PyInstaller...
python -m pip install pyinstaller --quiet
if errorlevel 1 (
    echo ERROR: No se pudo instalar PyInstaller
    pause
    exit /b 1
)

echo [2/3] Creando el ejecutable (esto puede tardar unos minutos)...
python -m PyInstaller --onefile --windowed --name "GestionClientes" --clean app.py
if errorlevel 1 (
    echo ERROR: No se pudo crear el ejecutable
    pause
    exit /b 1
)

echo [3/3] Limpiando archivos temporales...
if exist build rmdir /s /q build
if exist GestionClientes.spec del GestionClientes.spec

echo.
echo ========================================
echo   Ejecutable creado exitosamente!
echo ========================================
echo.
echo El archivo 'GestionClientes.exe' esta en la carpeta 'dist'
echo Puedes copiar ese archivo a cualquier computador y ejecutarlo directamente
echo.
pause

