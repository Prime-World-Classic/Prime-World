#define WIN32_LEAN_AND_MEAN

#include <windows.h>
#include <winsock2.h>
#include <ws2tcpip.h>
#include <stdlib.h>
#include <stdio.h>
#include <atomic>
#include <iostream>


// Need to link with Ws2_32.lib, Mswsock.lib, and Advapi32.lib
#pragma comment (lib, "Ws2_32.lib")
#pragma comment (lib, "Mswsock.lib")
#pragma comment (lib, "AdvApi32.lib")

static SOCKET ConnectSocket = INVALID_SOCKET;
std::atomic<bool> socketIsActive = false;

#define DEFAULT_BUFLEN 512
#define DEFAULT_PORT "34991"

void TransmitMessage(char const* strbuf, std::streamsize strSize) {
   if (socketIsActive.load()) {
      int iResult = send(ConnectSocket, strbuf, strSize, 0);
      if (iResult == SOCKET_ERROR) {
         socketIsActive = false;
         fprintf(stdout, "send failed with error: %d\n", WSAGetLastError());
         closesocket(ConnectSocket);
         WSACleanup();
      }
   }
}

int SocketTrancieve(const char* argv, std::atomic<bool>& doWork)
{
   WSADATA wsaData;
   struct addrinfo* result = NULL,
      * ptr = NULL,
      hints;
   const char* sendbuf = "this is a test";
   char recvbuf[DEFAULT_BUFLEN];
   int iResult;
   int recvbuflen = DEFAULT_BUFLEN;

   // Validate the parameters
   if (!argv) {
      return 1;
   }

   // Initialize Winsock
   iResult = WSAStartup(MAKEWORD(2, 2), &wsaData);
   if (iResult != 0) {
      fprintf(stdout, "WSAStartup failed with error: %d\n", iResult);
      return 1;
   }

   ZeroMemory(&hints, sizeof(hints));
   hints.ai_family = AF_UNSPEC;
   hints.ai_socktype = SOCK_STREAM;
   hints.ai_protocol = IPPROTO_TCP;

   // Resolve the server address and port
   iResult = getaddrinfo(argv, DEFAULT_PORT, &hints, &result);
   if (iResult != 0) {
      fprintf(stdout, "getaddrinfo failed with error: %d\n", iResult);
      WSACleanup();
      return 1;
   }

   // Attempt to connect to an address until one succeeds
   for (ptr = result; ptr != NULL; ptr = ptr->ai_next) {

      // Create a SOCKET for connecting to server
      ConnectSocket = socket(ptr->ai_family, ptr->ai_socktype,
         ptr->ai_protocol);
      if (ConnectSocket == INVALID_SOCKET) {
         fprintf(stdout, "socket failed with error: %ld\n", WSAGetLastError());
         WSACleanup();
         return 1;
      }

      // Connect to server.
      iResult = connect(ConnectSocket, ptr->ai_addr, (int)ptr->ai_addrlen);
      if (iResult == SOCKET_ERROR) {
         closesocket(ConnectSocket);
         ConnectSocket = INVALID_SOCKET;
         continue;
      }
      break;
   }

   freeaddrinfo(result);

   if (ConnectSocket == INVALID_SOCKET) {
      fprintf(stdout, "Unable to connect to server!\n");
      WSACleanup();
      return 1;
   }

   socketIsActive = true;
   /*
   if (false) { //////////////////////////////////////////////////////////
      // Send an initial buffer
      iResult = send(ConnectSocket, sendbuf, (int)strlen(sendbuf), 0);
      if (iResult == SOCKET_ERROR) {
         fprintf(stdout, "send failed with error: %d\n", WSAGetLastError());
         closesocket(ConnectSocket);
         WSACleanup();
         return 1;
      }
   } //////////////////////////////////////////////////////////
   */
   do {
      /*
      iResult = recv(ConnectSocket, recvbuf, recvbuflen, 0);
      if (iResult > 0)
         printf("Bytes received: %d\n", iResult);
      else if (iResult == 0)
         printf("Connection closed\n");
      else
         printf("recv failed with error: %d\n", WSAGetLastError());
         */
   } while (doWork.load());

   fprintf(stdout, "Bytes Sent: %ld\n", iResult);

   // shutdown the connection since no more data will be sent
   iResult = shutdown(ConnectSocket, SD_SEND);
   if (iResult == SOCKET_ERROR) {
      fprintf(stdout, "shutdown failed with error: %d\n", WSAGetLastError());
      closesocket(ConnectSocket);
      WSACleanup();
      return 1;
   }

   // Receive until the peer closes the connection
   do {
      /*
      iResult = recv(ConnectSocket, recvbuf, recvbuflen, 0);
      if (iResult > 0)
         printf("Bytes received: %d\n", iResult);
      else if (iResult == 0)
         printf("Connection closed\n");
      else
         printf("recv failed with error: %d\n", WSAGetLastError());
         */
   } while (doWork.load());

   // cleanup
   closesocket(ConnectSocket);
   WSACleanup();

   return 0;
}