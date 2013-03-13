/* -*- mode: objective-c; tab-width: 4; indent-tabs-mode: nil; encoding: utf-8 -*- */

#import "cli.h"
#import "aux.h"
#import <stdio.h>
#import <stdlib.h>

bool cli_confirm(void)
{
    char c;

    do
    {
        printf("\n(y/n): ");
        c = getchar();

    } while (c != 'y' && c != 'n');

    return (c == 'y');
}

void *cli_choice(void **choices, unsigned int num_choices, void (*label_func)(void *, char **, size_t))
{
    unsigned int i;

    for (i = 0; i < num_choices; ++i)
    {
        char label[1024] = {0};
        label_func(choices[i], &label, 1024);

        printf("%d) %s\n", i+1, label);
    }

    char *input = NULL;
    size_t input_len;
    long choice = 0;

    do
    {
        printf("> ");
        if (getline(&input, &input_len, stdin) != -1)
        {
            choice = strtol(input, NULL, 10);
        }

    } while ((choice < 1 || choice > num_choices) && !is_empty(input));

    if (input && is_empty(input))
    {
        return NULL;
    }
    else
    {
        return choices[choice - 1];
    }

}