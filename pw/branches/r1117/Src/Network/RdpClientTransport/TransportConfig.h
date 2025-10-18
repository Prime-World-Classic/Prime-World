#ifndef TRANSPORTCONFIG_H_INCLUDED
#define TRANSPORTCONFIG_H_INCLUDED

#include "System/NiTimer.h"

namespace rdp_transport
{

struct TransportConfig
{
    float loginTimeout;
    float channelTimeout;
    unsigned rdpLogEvents;
    int logicPriority;
    int sockServPriority;
    int sockBufferSize;
    size_t maxPacketSize;
    
    TransportConfig() :
        loginTimeout(30.0f),
        channelTimeout(15.0f),
        rdpLogEvents(0x07), // LogMajorEvents | LogWarnings | LogErrors
        logicPriority(1),
        sockServPriority(1),
        sockBufferSize(65536),
        maxPacketSize(16 * 1024)
    {}
};

namespace Constants
{
    const size_t MAX_BUFFER_SIZE = 64;
    const size_t MAX_PACKET_SIZE = 16 * 1024;
    const float DEFAULT_TIMEOUT = 15.0f;
}

} // namespace rdp_transport

#endif // TRANSPORTCONFIG_H_INCLUDED