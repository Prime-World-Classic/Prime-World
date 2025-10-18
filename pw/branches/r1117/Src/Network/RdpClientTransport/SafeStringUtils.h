#ifndef SAFESTRINGUTILS_H_INCLUDED
#define SAFESTRINGUTILS_H_INCLUDED

#include "stdafx.h"

namespace rdp_transport
{

class SafeStringUtils
{
public:
    static bool SafeCopyString(char* dest, size_t destSize, const char* src)
    {
        if (!dest || destSize == 0 || !src)
            return false;
            
        size_t srcLen = strlen(src);
        if (srcLen >= destSize)
            return false;
            
        STRCPY_S(dest, destSize, src);
        return true;
    }
    
    static bool SafeConcatenate(char* dest, size_t destSize, const char* src)
    {
        if (!dest || destSize == 0 || !src)
            return false;
            
        size_t currentLen = strlen(dest);
        size_t srcLen = strlen(src);
        
        if (currentLen + srcLen >= destSize)
            return false;
            
        STRCAT_S(dest, destSize, src);
        return true;
    }
};

} // namespace rdp_transport

#endif // SAFESTRINGUTILS_H_INCLUDED