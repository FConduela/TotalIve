#!/bin/bash
echo "========================================"
echo "  Creando Ejecutable de la Aplicacion"
echo "========================================"
echo ""

# Verificar si Python está instalado
if ! command -v python3 &> /dev/null; then
    echo "ERROR: Python3 no está instalado"
    echo "Por favor instala Python3 primero"
    exit 1
fi

echo "[1/3] Instalando PyInstaller..."
pip3 install pyinstaller --quiet
if [ $? -ne 0 ]; then
    echo "ERROR: No se pudo instalar PyInstaller"
    exit 1
fi

echo "[2/3] Creando el ejecutable (esto puede tardar unos minutos)..."
python3 -m PyInstaller --onefile --windowed --name "GestionClientes" --clean app.py
if [ $? -ne 0 ]; then
    echo "ERROR: No se pudo crear el ejecutable"
    exit 1
fi

echo "[3/3] Limpiando archivos temporales..."
rm -rf build
rm -f GestionClientes.spec

echo ""
echo "========================================"
echo "  Ejecutable creado exitosamente!"
echo "========================================"
echo ""
echo "El archivo 'GestionClientes' está en la carpeta 'dist'"
echo "Puedes copiar ese archivo a cualquier computador y ejecutarlo directamente"
echo ""

