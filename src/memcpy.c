#include <lpc_memcpy.h>

void * sqmemcpy( void * restrict s1, const void * restrict s2, size_t n )
{
    char * dest = (char *) s1;
    const char * src = (const char *) s2;
    while ( n-- )
    {
        *dest++ = *src++;
    }
    return s1;
}
