import socket
import threading
import time
import logging
import os
import sys
from logging.handlers import TimedRotatingFileHandler

log_directory = './udp_logs/'  #
os.makedirs(log_directory, exist_ok=True)  #  ,

log_file_path = os.path.join(log_directory, 'udp_relay.log')
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

class RelayServer:
    def __init__(self, relay_host, relay_ports_range, main_server_host):
        self.relay_host = relay_host
        self.relay_ports_range = relay_ports_range  # (34000, 34010)
        self.main_server_host = main_server_host    # (ip, port)
        
        # Маппинги:
        self.client_to_relay = {}  # (client_ip, client_port, dst_port) → relay_port
        self.relay_to_client = {}  # relay_port → (client_ip, client_port, socket)
        self.last_active_time = {}  # relay_port → timestamp
        
        # Сокеты для клиентов (34000-34010)
        self.client_sockets = {}
        self._init_client_sockets()

        #self.response_socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        #self.response_socket.bind((self.relay_host, 0))
        
        # Поток для очистки неактивных маппингов
        self.cleanup_thread = threading.Thread(target=self._cleanup_mappings, daemon=True)
        self.cleanup_thread.start()

    def _init_client_sockets(self):
        #"""Создаёт сокеты для клиентов на портах 34000-34010."""
        for port in range(*self.relay_ports_range):
            sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
            sock.bind((self.relay_host, port))
            self.client_sockets[port] = sock
            threading.Thread(target=self._handle_client_packet, args=(sock,), daemon=True).start()

    def _handle_client_packet(self, sock):
        #"""Обрабатывает пакеты от клиентов."""
        while True:
            data, (client_ip, client_port) = sock.recvfrom(65535)
            dst_port = sock.getsockname()[1]  # Порт, на который клиент отправил (34000-34010)
            relay_port = 0
            
            # Если клиент уже есть в маппинге, используем его relay_port
            try:
                main_server_addr = (self.main_server_host, dst_port)
                if (client_ip, client_port, dst_port) in self.client_to_relay:
                    relay_port = self.client_to_relay[(client_ip, client_port, dst_port)]
                    relay_sock = self.relay_to_client[relay_port][2][0]
                    #print(f"Reusing port {relay_port}")
                    relay_sock.sendto(data, main_server_addr)
                    #print(f"{client_ip} sends: {data}")
                else:
                    # Пытаемся занять новый порт
                    relay_sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
                    relay_sock.bind((self.relay_host, 0))
                    #print(f"Opened port {relay_port}")
                    relay_sock.sendto(data, main_server_addr)
                    #print(f"{client_ip} sends: {data}")
                    relay_port = relay_sock.getsockname()[1]
                    if relay_port is None:
                        logging.info(f"[ERROR] No free relay ports available")
                        continue

                    self._add_mapping(client_ip, client_port, relay_port, (relay_sock, sock))
                    threading.Thread(target=self.listen_response, args=(relay_sock,), daemon=True).start()
            except OSError as e:
                logging.info(f"[ERROR] Failed to send via relay port {relay_port}: {e}")
                self._remove_mapping(relay_port)
            
            # Обновляем время активности
            self.last_active_time[relay_port] = time.time()

    def listen_response(self, relay_sock):
        """Слушает ответы от сервера и пересылает клиентам."""
        while True:
            data, (server_ip, server_port) = relay_sock.recvfrom(65535)
            relay_port = relay_sock.getsockname()[1]  # Порт, на который сервер отправил ответ

            if relay_port in self.relay_to_client:
                client_ip, client_port, (r_sock, client_sock) = self.relay_to_client[relay_port]
                #print(f"Received response for {client_ip} : {client_port}")
                client_sock.sendto(data, (client_ip, client_port))
                #print(f"{client_ip} sends: {data}")
                self.last_active_time[relay_port] = time.time()  # Обновляем активность
            else:
                print(f"[WARN] Unknown relay port: {relay_port}")
                return


    def _add_mapping(self, client_ip, client_port, relay_port, relay_sock):
        #"""Добавляет запись в маппинги."""dst_port
        dst_port = relay_sock[1].getsockname()[1]
        self.client_to_relay[(client_ip, client_port, dst_port)] = relay_port
        self.relay_to_client[relay_port] = (client_ip, client_port, relay_sock)
        self.last_active_time[relay_port] = time.time()

    def _remove_mapping(self, relay_port):
        #"""Удаляет маппинг и закрывает сокет."""
        if relay_port in self.relay_to_client:
            _, _, sock = self.relay_to_client[relay_port]
            sock[0].close()
            del self.relay_to_client[relay_port]
            del self.last_active_time[relay_port]
            
            # Удаляем из client_to_relay (медленно, но необходимо)
            for key, val in list(self.client_to_relay.items()):
                if val == relay_port:
                    del self.client_to_relay[key]
                    break

    def _cleanup_mappings(self, timeout=60):
        #"""Удаляет неактивные маппинги."""
        while True:
            time.sleep(timeout)
            current_time = time.time()
            inactive_ports = [
                port for port, last_active in self.last_active_time.items()
                if current_time - last_active > timeout
            ]
            for port in inactive_ports:
                self._remove_mapping(port)
            logging.info(f"[INFO] Cleaned up {len(inactive_ports)} inactive mappings")

    def start_response_listener(self):
        #"""Слушает ответы от сервера и пересылает клиентам."""
        while True:
            logging.info('Active connections:')
            items_list = list(self.client_to_relay.items())
            for key, value in items_list:
                logging.info(f"Key: {key}, Value: {value}")
            time.sleep(10)
            continue
            #data, (server_ip, server_port) = self.response_socket.recvfrom(65535)
            #relay_port = server_port  # Порт, на который сервер отправил ответ
            #
            #if relay_port in self.relay_to_client:
            #    client_ip, client_port = self.relay_to_client[relay_port]
            #    self.response_socket.sendto(data, (client_ip, client_port))
            #    self.last_active_time[relay_port] = time.time()  # Обновляем активность
            #else:
            #    print("[WARN] Unknown relay port: {relay_port}")

if __name__ == "__main__":
    RELAY_HOST = "0.0.0.0"
    RELAY_PORTS_RANGE = (27301, 27360)  # 34000-34010
    MAIN_SERVER_HOST = "81.88.210.30"
    
    relay = RelayServer(RELAY_HOST, RELAY_PORTS_RANGE, MAIN_SERVER_HOST)
    relay.start_response_listener()  # Запускаем обработчик ответов