@echo off
chcp 65001 >nul
title Crear Ejecutable - Gestion de Clientes
color 0A

echo.
echo ╔══════════════════════════════════════════════════════════╗
echo ║     CREAR EJECUTABLE - GESTION DE CLIENTES              ║
echo ╚══════════════════════════════════════════════════════════╝
echo.

REM Verificar Python
echo [✓] Verificando Python...
python --version >nul 2>&1
if errorlevel 1 (
    color 0C
    echo [✗] ERROR: Python no está instalado
    echo.
    echo Por favor instala Python desde: https://www.python.org/downloads/
    echo Durante la instalación, marca "Add Python to PATH"
    echo.
    pause
    exit /b 1
)
python --version
echo.

REM Instalar PyInstaller
echo [1/3] Instalando PyInstaller...
python -m pip install --upgrade pip --quiet
python -m pip install pyinstaller --quiet
if errorlevel 1 (
    color 0C
    echo [✗] ERROR: No se pudo instalar PyInstaller
    echo.
    pause
    exit /b 1
)
echo [✓] PyInstaller instalado correctamente
echo.

REM Crear ejecutable
echo [2/3] Creando ejecutable...
echo     Esto puede tardar 2-5 minutos, por favor espera...
echo.
python -m PyInstaller --onefile --windowed --name "GestionClientes" --clean --noconfirm app.py
if errorlevel 1 (
    color 0C
    echo [✗] ERROR: No se pudo crear el ejecutable
    echo.
    pause
    exit /b 1
)
echo.

REM Limpiar
echo [3/3] Limpiando archivos temporales...
if exist build rmdir /s /q build >nul 2>&1
if exist GestionClientes.spec del GestionClientes.spec >nul 2>&1

color 0A
echo.
echo ╔══════════════════════════════════════════════════════════╗
echo ║           ¡EJECUTABLE CREADO EXITOSAMENTE!              ║
echo ╚══════════════════════════════════════════════════════════╝
echo.
echo 📁 Ubicación: dist\GestionClientes.exe
echo.
echo ✅ Puedes copiar el archivo .exe a cualquier computador
echo ✅ No necesita Python ni dependencias instaladas
echo ✅ Ejecútalo con doble clic
echo.
echo Presiona cualquier tecla para abrir la carpeta 'dist'...
pause >nul

REM Abrir carpeta dist
if exist dist start dist
exit

