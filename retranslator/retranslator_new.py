# -*- coding: utf-8 -*-
import asyncio
import websockets
import ssl
import logging
import os
import sys
from logging.handlers import TimedRotatingFileHandler

#     ,    -
log_directory = './'  #    
os.makedirs(log_directory, exist_ok=True)  #  ,    

#         
log_file_path = os.path.join(log_directory, 'websocket_relay.log')
handler = TimedRotatingFileHandler(log_file_path, when="midnight", interval=1, backupCount=7)  #    7 
formatter = logging.Formatter('%(asctime)s - %(levelname)s - %(message)s')
handler.setFormatter(formatter)


stdout_handler = logging.StreamHandler(sys.stdout)
stdout_handler.setLevel(logging.DEBUG)
stdout_handler.setFormatter(formatter)

logging.basicConfig(
    handlers=[handler, stdout_handler],
    level=logging.INFO
)


async def relay(websocket):  # :   path
    logging.info("Connected to remote server!")
    remote_uri = "http://remote.server:27302/api"
    if websocket.request.path:
        remote_uri = "http://remote.server:27302/api" + websocket.request.path
    #     
    try:
        async with websockets.connect(remote_uri, ssl=None) as remote:
            logging.info("Connected to remote server: %s", remote_uri)

            async def receive():
                while True:
                    try:
                        data = await websocket.recv()  #    
                        logging.info("Received data from client: %s", data)
                        await remote.send(data)  #     
                        logging.info("Sent data to remote server")
                    except websockets.exceptions.ConnectionClosed:
                        logging.warning("Client connection closed")
                        break

            async def response():
                while True:
                    try:
                        response = await remote.recv()  #     
                        logging.info("Received data from remote server: %s", response)
                        await websocket.send(response)  #    
                        logging.info("Sent data to client")
                    except websockets.exceptions.ConnectionClosed:
                        logging.warning("Remote server connection closed")
                        break

            #       
            f1 = asyncio.create_task(receive())
            f2 = asyncio.create_task(response())
            await asyncio.wait([f1, f2])  #    

    except Exception as e:
        logging.error("Error connecting to remote server: %s", e)

#  SSL 
#ssl_context = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
#ssl_context.load_cert_chain('/volume1/homes/admin/relay/.pem', '/volume1/homes/admin/relay/.key')

async def main():
    #  WebSocket 
    start_server = await websockets.serve(relay, "127.0.0.1", 27302, ssl=None)
    logging.info("Server started on http://127.0.0.1:27302")  #   wss   
    await start_server.wait_closed()  #   

#    
if __name__ == "__main__":
    asyncio.run(main())