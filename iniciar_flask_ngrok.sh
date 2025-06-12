#!/bin/bash

echo "🚀 Iniciando entorno para tu agente CodeGPT..."

# 🛑 Cerrar procesos previos de ngrok
echo "🔍 Cerrando sesiones anteriores de ngrok (si las hay)..."
NGROK_PIDS=$(pgrep -f "ngrok http")
if [ -n "$NGROK_PIDS" ]; then
  kill $NGROK_PIDS
  echo "✅ ngrok anterior cerrado."
else
  echo "✅ No había ngrok corriendo."
fi

# 🛑 Cerrar procesos previos de Flask en el puerto 5000
echo "🔍 Cerrando servidores Flask activos en el puerto 5000..."
FLASK_PIDS=$(lsof -ti:5000)
if [ -n "$FLASK_PIDS" ]; then
  kill $FLASK_PIDS
  echo "✅ Flask anterior cerrado."
else
  echo "✅ No había Flask en ejecución."
fi

# 📦 Activar entorno virtual
if [ -d "venv" ]; then
  echo "📦 Activando entorno virtual..."
  source venv/bin/activate
else
  echo "⚠️ No se encontró el entorno virtual (venv/). Ejecuta: python3 -m venv venv"
  exit 1
fi

# 🧠 Iniciar Flask en nueva ventana de Terminal
echo "🧠 Iniciando servidor Flask..."
osascript -e 'tell app "Terminal" to do script "cd \"'$(pwd)'\" && source venv/bin/activate && python3 app.py"'

sleep 8

# 🌐 Iniciar ngrok en segundo plano
echo "🌐 Iniciando ngrok..."
ngrok http 5000 > /dev/null &
NGROK_PID=$!

# Esperar que ngrok esté listo y tenga un túnel abierto
echo "⏳ Esperando URL pública desde la API local de ngrok..."
for i in {1..10}; do
  NGROK_URL=$(curl -s http://127.0.0.1:4040/api/tunnels | grep -o 'https://[a-zA-Z0-9]*\.ngrok\.io' | head -1)
  if [ -n "$NGROK_URL" ]; then
    break
  fi
  sleep 1
done

# Mostrar o fallar
if [ -n "$NGROK_URL" ]; then
  echo ""
  echo "✅ Tu servidor Flask está accesible públicamente en:"
  echo "🔗 $NGROK_URL/upload"
  echo "$NGROK_URL/upload" | pbcopy
  echo "📋 La URL se copió automáticamente al portapapeles. ¡Pégala directo en Make!"
else
  echo "❌ No se pudo obtener la URL desde la API de ngrok. ¿Está corriendo correctamente?"
fi

# 📂 Mostrar archivos en la carpeta knowledge/
echo ""
echo "📂 Archivos actualmente en la carpeta 'knowledge/':"
if [ -d "knowledge" ]; then
  ls -1 knowledge/
else
  echo "⚠️ La carpeta 'knowledge/' no existe aún."
fi

# 🧼 Limpieza al cerrar
trap "kill $NGROK_PID" EXIT
wait $NGROK_PID
