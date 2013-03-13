/* -*- mode: objective-c; tab-width: 4; indent-tabs-mode: nil -*- */

#import "hid.h"
#import <stdio.h>
#import <string.h>

bool hid_get_interface_descriptor(struct libusb_device *dev, struct libusb_interface_descriptor *iface)
{
    int rc;
    struct libusb_config_descriptor *config;

    if ((rc = libusb_get_active_config_descriptor(dev, &config)) != LIBUSB_SUCCESS)
    {
        fprintf(stderr, "error retrieving active config descriptor (%s) \n", libusb_error_name(rc));
        return false;
    }

    unsigned int i, a;
    bool ret = false;

    for (i = 0; i < config->bNumInterfaces; ++i)
    {
        for (a = 0; a < config->interface[i].num_altsetting; ++a)
        {
            if (config->interface[i].altsetting[a].bInterfaceClass == 3) // HID
            {
                memcpy(iface, &(config->interface[i].altsetting[a]), sizeof(struct libusb_interface_descriptor));
                ret = true;
            }
        }
    }

    libusb_free_config_descriptor(config);

    return ret;
}