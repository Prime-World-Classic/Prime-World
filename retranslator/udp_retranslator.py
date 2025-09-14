import socket
import threading
import time
import logging
import os
import sys
from logging.handlers import TimedRotatingFileHandler

RELAY_HOST = "0.0.0.0"
RELAY_PORTS_RANGE = [27301] + list(range(27340, 27360))
MAIN_SERVER_HOST = "8.8.8.8" # Enter valid server IP here

RELAY_SOCKET_TIMEOUT = 120
CLEANUP_TIMEOUT = 120
LOGGING_INFO_TIMEOUT = 60

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
        self.relay_ports_range = relay_ports_range
        self.main_server_host = main_server_host    # (ip, port)

        # Маппинги:
        self.client_to_relay = {}  # (client_ip, client_port, dst_port) → relay_port
        self.relay_to_client = {}  # relay_port → (client_ip, client_port, socket)
        self.last_active_time = {}  # relay_port → timestamp

        # Сокеты для клиентов
        self.client_sockets = {}
        self._init_client_sockets()

        # Поток для очистки неактивных маппингов
        self.cleanup_thread = threading.Thread(target=self._cleanup_mappings, daemon=True)
        self.cleanup_thread.start()

    def _init_client_sockets(self):
        #"""Создаёт сокеты для клиентов на портах 34000-34010."""
        for port in self.relay_ports_range:
            sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
            sock.bind((self.relay_host, port))
            self.client_sockets[port] = sock
            threading.Thread(target=self._handle_client_packet, args=(sock,), daemon=True).start()

    def _handle_client_packet(self, sock):
        #"""Обрабатывает пакеты от клиентов."""
        while True:
            try:
                data, (client_ip, client_port) = sock.recvfrom(65535)
                dst_port = sock.getsockname()[1]  # Порт, на который клиент отправил
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
                        relay_sock.settimeout(RELAY_SOCKET_TIMEOUT)
                        relay_sock.bind((self.relay_host, 0))
                        relay_sock.sendto(data, main_server_addr)
                        #print(f"{client_ip} sends: {data}")
                        relay_port = relay_sock.getsockname()[1]
                        logging.info(f"Opened connection {relay_port} for {client_ip}")
                        if relay_port is None:
                            logging.info(f"[ERROR] No free relay ports available")
                            continue

                        self._add_mapping(client_ip, client_port, relay_port, (relay_sock, sock))
                        threading.Thread(target=self.listen_response, args=(relay_port,), daemon=True).start()
                except OSError as e:
                    logging.info(f"[ERROR] Failed to send via relay port {relay_port}: {e}")
                    self._remove_mapping(relay_port)

                # Обновляем время активности
                #logging.info(f"[INFO] Active client connection {relay_port}")
                self.last_active_time[relay_port] = time.time()
            except Exception as e:
                logging.error(f"[ERROR] Unexpected error in _handle_client_packet: {e}")

    def listen_response(self, relay_port):
        """Слушает ответы от сервера и пересылает клиентам."""
        while True:
            if relay_port in self.relay_to_client:
                _, _, (relay_sock, client_sock), socket_lock = self.relay_to_client[relay_port]
                #logging.error(f"[INFO] Acquiring lock: {relay_port}")
                with socket_lock:
                    #logging.error(f"[INFO] Acquired lock: {relay_port}")
                    try:
                        data, (server_ip, server_port) = relay_sock.recvfrom(65535)
                        relay_port = relay_sock.getsockname()[1]  # Порт, на который сервер отправил ответ

                        if relay_port in self.relay_to_client:
                            client_ip, client_port, (r_sock, client_sock), _ = self.relay_to_client[relay_port]
                            #print(f"Received response for {client_ip} : {client_port}")
                            client_sock.sendto(data, (client_ip, client_port))
                            #print(f"{client_ip} sends: {data}")
                            self.last_active_time[relay_port] = time.time()  # Обновляем активность
                            #logging.info(f"[INFO] Active server connection {relay_port}")
                        else:
                            logging.info(f"[WARN] Unknown relay port: {relay_port}")
                            return
                    except Exception as e:
                        logging.error(f"[ERROR] Unexpected error in listen_response: {e}")
                #logging.error(f"[INFO] Released lock: {relay_port}")
            else:
                logging.info(f"[WARN] Relay port was not found - return: {relay_port}")
                return

    def _add_mapping(self, client_ip, client_port, relay_port, relay_sock):
        #"""Добавляет запись в маппинги."""dst_port
        dst_port = relay_sock[1].getsockname()[1]
        self.client_to_relay[(client_ip, client_port, dst_port)] = relay_port
        self.relay_to_client[relay_port] = (client_ip, client_port, relay_sock, threading.Lock())
        self.last_active_time[relay_port] = time.time()

    def _remove_mapping(self, relay_port):
        #"""Удаляет маппинг и закрывает сокет."""
        logging.error(f"[INFO] Removing mapping: {relay_port}")
        if relay_port in self.relay_to_client:
            _, _, (relay_sock, client_sock), socket_lock = self.relay_to_client[relay_port]
            #logging.error(f"[INFO] Acquiring lock: {relay_port}")
            with socket_lock:
                #logging.error(f"[INFO] Acquired lock: {relay_port}")
                try:
                    relay_sock.close()
                    #client_sock.close()
                except Exception as e:
                    logging.error(f"[ERROR] Something went wrong: {e}")

                del self.relay_to_client[relay_port]
                if relay_port in self.last_active_time:
                    del self.last_active_time[relay_port]

                # Удаляем из client_to_relay (медленно, но необходимо)
                for key, val in list(self.client_to_relay.items()):
                    if val == relay_port:
                        del self.client_to_relay[key]
                        break
                logging.error(f"[INFO] Finished mapping removing: {relay_port}")
                #logging.error(f"[INFO] Released lock: {relay_port}")

    def _cleanup_mappings(self, timeout=CLEANUP_TIMEOUT):
        #"""Удаляет неактивные маппинги."""
        while True:
            try:
                time.sleep(1)
                current_time = time.time()
                inactive_ports = [
                    port for port, last_active in self.last_active_time.items()
                    if current_time - last_active > timeout
                ]
                if len(inactive_ports):
                    logging.info(f"[INFO] Connections to clean {list(inactive_ports)}")
                    logging.info(f"[INFO] Active connections: {list(self.relay_to_client)}")
                for port in inactive_ports:
                    self._remove_mapping(port)
                if len(inactive_ports):
                    logging.info(f"[INFO] Cleaned up {len(inactive_ports)} inactive mappings")
            except Exception as e:
                logging.error(f"[ERROR] Unexpected error in _cleanup_mappings: {e}")

    def start_response_listener(self):
        #"""Слушает ответы от сервера и пересылает клиентам."""
        while True:
            logging.info('Active connections:')
            items_list = list(self.client_to_relay.items())
            for key, value in items_list:
                logging.info(f"Key: {key}, Value: {value}")

            logging.info(f"self.client_to_relay: {len(self.client_to_relay)}, self.relay_to_client: {len(self.relay_to_client)}")
            logging.info(f"self.last_active_time: {len(self.last_active_time)}, self.client_sockets: {len(self.client_sockets)}")

            for thread in threading.enumerate():
                logging.info(thread.name)

            time.sleep(LOGGING_INFO_TIMEOUT)


if __name__ == "__main__":
    relay = RelayServer(RELAY_HOST, RELAY_PORTS_RANGE, MAIN_SERVER_HOST)
    relay.start_response_listener()  # Запускаем обработчик ответов
