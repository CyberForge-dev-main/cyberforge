FROM python:3.11-slim

WORKDIR /app

# Установка зависимостей
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Копирование кода
COPY . .

# Порт Flask
EXPOSE 5000

# Запуск приложения
CMD ["python", "app.py"]
