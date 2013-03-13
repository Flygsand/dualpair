/* -*- mode: objective-c; tab-width: 4; indent-tabs-mode: nil; encoding: utf-8 -*- */

#import "aux.h"
#import <stdio.h>
#import <string.h>

void format_btaddr(const uint8_t *addr, char *outbuf, size_t outbuf_len)
{
    snprintf(outbuf, outbuf_len, "%x:%x:%x:%x:%x:%x", addr[0], addr[1], addr[2], addr[3], addr[4], addr[5]);
}

void *array_from_nsarray(const NSArray *arr)
{
    unsigned long count = [arr count];
    NSObject **c_arr = malloc(sizeof(NSObject *) * count);

    if (c_arr)
    {
        unsigned long i;
        for (i = 0; i < count; ++i)
        {
            c_arr[i] = [arr objectAtIndex:i];
            [c_arr[i] retain];
        }
    }

    return c_arr;
}

void free_nsobject_array(NSObject **arr, unsigned int count)
{
    unsigned int i;

    for (i = 0; i < count; ++i)
    {
        [arr[i] release];
    }

    free(arr);
}

bool is_empty(const char *str)
{
    while (isspace((unsigned char) *str))
    {
        ++str;
    }

    return (*str == '\0');
}