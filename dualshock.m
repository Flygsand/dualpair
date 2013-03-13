/* -*- mode: objective-c; tab-width: 4; indent-tabs-mode: nil; encoding: utf-8 -*- */

#import "dualshock.h"
#import "aux.h"
#import "hid.h"
#import <stdio.h>

bool ds_set_master(struct libusb_device_handle *dev_handle, const uint8_t *master)
{
    int nbytes;
    uint8_t data[8] = {0x01, 0x00, master[0], master[1], master[2], master[3], master[4], master[5]};
    struct libusb_interface_descriptor iface;
    struct libusb_device *dev = libusb_get_device(dev_handle);

    if (hid_get_interface_descriptor(dev, &iface))
    {
        nbytes = libusb_control_transfer(dev_handle, 
                                         LIBUSB_ENDPOINT_OUT | LIBUSB_REQUEST_TYPE_CLASS | LIBUSB_RECIPIENT_INTERFACE, 
                                         LIBUSB_REQUEST_SET_CONFIGURATION, 
                                         0x03f5,
                                         iface.bInterfaceNumber,
                                         data,
                                         sizeof(data),
                                         5000
                                        );
       
        if (nbytes < 0) {
            fprintf(stderr, "error: control transfer failed (%s)\n", libusb_error_name(nbytes));
            return false;
        }

        return true;
    }

    return false;

}

bool ds_get_master(struct libusb_device_handle *dev_handle, uint8_t *master)
{
    int nbytes;
    struct libusb_interface_descriptor iface;
    struct libusb_device *dev = libusb_get_device(dev_handle);
    uint8_t data[8] = {0};

    if (hid_get_interface_descriptor(dev, &iface))
    {
        nbytes = libusb_control_transfer(dev_handle,
                                        LIBUSB_ENDPOINT_IN | LIBUSB_REQUEST_TYPE_CLASS | LIBUSB_RECIPIENT_INTERFACE,
                                        0x01,
                                        0x03f5,
                                        iface.bInterfaceNumber,
                                        data,
                                        sizeof(data),
                                        5000
                                        );

        if (nbytes < 0)
        {
            fprintf(stderr, "error: control transfer failed (%s)\n", libusb_error_name(nbytes));
            return false;
        }
        else if (nbytes < 8)
        {
            fprintf(stderr, "error: device did not return enough data (%d bytes out of 8)\n", nbytes);
            return false;
        }

        memcpy(master, data + 2, 6);

        return true;

    }

    return false;
}
