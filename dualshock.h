/* -*- mode: objective-c; tab-width: 4; indent-tabs-mode: nil; encoding: utf-8 -*- */

#ifndef __DUALPAIR__DUALSHOCK_H__
#define __DUALPAIR__DUALSHOCK_H__

#import <libusb.h>
#import <stdint.h>
#import <stdbool.h>
#import <string.h>

#define DS_VENDOR_ID 0x054c
#define DS_PRODUCT_ID 0x0268

// bool ds_set_operational(libusb_device_handle *dev_handle);
bool ds_set_master(struct libusb_device_handle *dev_handle, const uint8_t *master);
bool ds_get_master(struct libusb_device_handle *dev_handle, uint8_t *master);

#endif