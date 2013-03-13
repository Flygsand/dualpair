/* -*- mode: objective-c; tab-width: 4; indent-tabs-mode: nil -*- */

#ifndef __DUALPAIR__HID_H__
#define __DUALPAIR__HID_H__

#import <libusb.h>
#import <stdbool.h>

bool hid_get_interface_descriptor(struct libusb_device *dev, struct libusb_interface_descriptor *iface);

#endif