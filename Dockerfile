# Usa una imagen base oficial de Python
FROM python:3.9-slim

# Establece el directorio de trabajo en el contenedor
WORKDIR /app

# Copia los archivos del proyecto al directorio de trabajo
COPY . /app

# (Opcional) Expone el puerto 9091 en caso de que decidas levantar un servidor web más adelante
# o usarlo para alguna comunicación.
EXPOSE 9091

# Comando por defecto para ejecutar la aplicación
CMD ["python", "hola_mundo.py"]
