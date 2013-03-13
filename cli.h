/* -*- mode: objective-c; tab-width: 4; indent-tabs-mode: nil; encoding: utf-8 -*- */

#ifndef __DUALPAIR__CLI_H__
#define __DUALPAIR__CLI_H__

#import <stdbool.h>
#import <string.h>

bool cli_confirm(void);
void *cli_choice(void **choices, unsigned int num_choices, void (*label_func)(void *, char **, size_t));

#endif