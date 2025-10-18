#pragma once

#include "System/systemStdAfx.h"
#include <string>
#include <vector>
#include <map>
#include <algorithm>

// Безопасные функции для VS2008
#ifdef _MSC_VER
#define STRCPY_S(dest, size, src) strcpy_s(dest, size, src)
#define STRNCPY_S(dest, size, src, count) strncpy_s(dest, size, src, count)
#define STRCAT_S(dest, size, src) strcat_s(dest, size, src)
#else
#define STRCPY_S(dest, size, src) strcpy(dest, src)
#define STRNCPY_S(dest, size, src, count) strncpy(dest, src, count)
#define STRCAT_S(dest, size, src) strcat(dest, src)
#endif