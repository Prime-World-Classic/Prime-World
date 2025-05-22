# -*- coding: utf-8 -*-
import asyncio
import websockets
import ssl
import logging
import os
from logging.handlers import TimedRotatingFileHandler

# Укажите полный путь к директории, где хотите сохранить лог-файл
log_directory = './'  # Замените на нужный путь
os.makedirs(log_directory, exist_ok=True)  # Создайте директорию, если она не существует

# Настройка логирования для записи в файл с ежедневной ротацией
log_file_path = os.path.join(log_directory, 'websocket_relay.log')
handler = TimedRotatingFileHandler(log_file_path, when="midnight", interval=1, backupCount=7)  # Хранить логи за 7 дней
formatter = logging.Formatter('%(asctime)s - %(levelname)s - %(message)s')
handler.setFormatter(formatter)

logging.basicConfig(
    handlers=[handler],
    level=logging.INFO
)

async def relay(websocket):  # Изменено: убран аргумент path
    remote_uri = "wss://playpw.fun:443/api/v1/"
    if websocket.request.path:
        remote_uri = "wss://playpw.fun:443/api/v1/" + websocket.request.path
    # Устанавливаем соединение с удаленным сервером
    try:
        async with websockets.connect(remote_uri, ssl=ssl.SSLContext()) as remote:
            logging.info("Connected to remote server: %s", remote_uri)

            async def receive():
                while True:
                    try:
                        data = await websocket.recv()  # Получаем данные от клиента
                        logging.info("Received data from client: %s", data)
                        await remote.send(data)  # Отправляем данные на удаленный сервер
                        logging.info("Sent data to remote server")
                    except websockets.exceptions.ConnectionClosed:
                        logging.warning("Client connection closed")
                        break

            async def response():
                while True:
                    try:
                        response = await remote.recv()  # Получаем данные от удаленного сервера
                        logging.info("Received data from remote server: %s", response)
                        await websocket.send(response)  # Отправляем данные обратно клиенту
                        logging.info("Sent data to client")
                    except websockets.exceptions.ConnectionClosed:
                        logging.warning("Remote server connection closed")
                        break

            # Запускаем задачи для получения и отправки данных
            f1 = asyncio.create_task(receive())
            f2 = asyncio.create_task(response())
            await asyncio.wait([f1, f2])  # Ожидаем завершения обеих задач

    except Exception as e:
        logging.error("Error connecting to remote server: %s", e)

# Создание SSL контекста
ssl_context = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
ssl_context.load_cert_chain('./cert.pem', './cert.key')

async def main():
    # Запуск WebSocket сервера
    start_server = await websockets.serve(relay, "192.168.0.12", 8443, ssl=ssl_context)
    logging.info("Server started on wss://192.168.0.12:8443")  # Изменено на wss для безопасного соединения
    await start_server.wait_closed()  # Ожидание закрытия сервера

# Запуск основного асинхронного кода
if __name__ == "__main__":
    asyncio.run(main())