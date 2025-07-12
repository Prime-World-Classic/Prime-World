from http.server import HTTPServer, BaseHTTPRequestHandler
from urllib.parse import urlparse
import requests
import logging
import os
import sys
from logging.handlers import TimedRotatingFileHandler

log_directory = './'  #    
os.makedirs(log_directory, exist_ok=True)  #  ,    

log_file_path = os.path.join(log_directory, 'http_relay.log')
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

class ProxyHTTPRequestHandler(BaseHTTPRequestHandler):
    # Укажите здесь адрес целевого сервера, на который нужно перенаправлять запросы
    TARGET_SERVER = "http://remote.server:27302"  # Замените на нужный URL

    def do_GET(self):
        self.proxy_request()

    def do_POST(self):
        self.proxy_request()

    def do_PUT(self):
        self.proxy_request()

    def do_DELETE(self):
        self.proxy_request()

    def do_HEAD(self):
        self.proxy_request()

    def do_OPTIONS(self):
        self.proxy_request()

    def proxy_request(self):
        # Получаем заголовки от клиента (исключая Hop-by-hop заголовки)
        headers = {k: v for k, v in self.headers.items()}
        
        # Удаляем заголовки, которые не должны передаваться дальше
        hop_by_hop = ['connection', 'keep-alive', 'proxy-authenticate', 
                      'proxy-authorization', 'te', 'trailers', 'transfer-encoding', 'upgrade']
        for h in hop_by_hop:
            if h in headers:
                del headers[h]

        # Формируем URL для целевого сервера
        target_url = f"{self.TARGET_SERVER}{self.path}"

        try:
            # Отправляем запрос к целевому серверу
            if self.command == "GET":
                resp = requests.get(target_url, headers=headers, stream=True)
            elif self.command == "POST":
                content_length = int(self.headers.get('Content-Length', 0))
                post_data = self.rfile.read(content_length)
                resp = requests.post(target_url, headers=headers, data=post_data, stream=True)
            elif self.command == "PUT":
                content_length = int(self.headers.get('Content-Length', 0))
                put_data = self.rfile.read(content_length)
                resp = requests.put(target_url, headers=headers, data=put_data, stream=True)
            elif self.command == "DELETE":
                resp = requests.delete(target_url, headers=headers, stream=True)
            elif self.command == "HEAD":
                resp = requests.head(target_url, headers=headers, stream=True)
            elif self.command == "OPTIONS":
                resp = requests.options(target_url, headers=headers, stream=True)

            logging.info(resp.text)
            # Отправляем статус и заголовки клиенту
            self.send_response(resp.status_code)
            for header, value in resp.headers.items():
                if header.lower() not in hop_by_hop:
                    self.send_header(header, value)
            self.end_headers()

            # Отправляем тело ответа клиенту
            for chunk in resp.iter_content(1024):
                self.wfile.write(chunk)

        except Exception as e:
            self.send_error(500, f"Proxy error: {str(e)}")

def run(server_class=HTTPServer, handler_class=ProxyHTTPRequestHandler, port=27302):
    server_address = ('127.0.0.1', port)
    httpd = server_class(server_address, handler_class)
    logging.info(f"Starting proxy server on port {port}...")
    httpd.serve_forever()

if __name__ == '__main__':
    run()