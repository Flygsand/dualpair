/* -*- mode: objective-c; tab-width: 4; indent-tabs-mode: nil; encoding: utf-8 -*- */

#ifndef __DUALPAIR__AUX_H__
#define __DUALPAIR__AUX_H__

#import <Foundation/Foundation.h>
#import <stdint.h>
#import <string.h>
#import <stdbool.h>

void format_btaddr(const uint8_t *addr, char *outbuf, size_t outbuf_len);
void *array_from_nsarray(const NSArray *arr);
void free_nsobject_array(NSObject **arr, unsigned int count);
bool is_empty(const char *str);

#endif