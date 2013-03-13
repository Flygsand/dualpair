/* -*- mode: objective-c; tab-width: 4; indent-tabs-mode: nil; encoding: utf-8 -*- */

#import <stdio.h>
#import <stdbool.h>
#import <signal.h>
#import <sys/queue.h>
#import <sys/time.h>
#import <libusb.h>
#import <Foundation/Foundation.h>
#import <IOBluetooth/objc/IOBluetoothDevice.h>
#import "BluetoothScan.h"
#import "dualshock.h"
#import "cli.h"
#import "aux.h"

struct hotplug_queue_entry 
{
    struct libusb_device_handle *dev_handle;
    bool processed;

    TAILQ_ENTRY(hotplug_queue_entry) entries;
};

TAILQ_HEAD(hotplug_queue, hotplug_queue_entry);

static bool run = true;
static libusb_hotplug_callback_handle hp[2];
static struct hotplug_queue hpq = TAILQ_HEAD_INITIALIZER(hpq);
static BluetoothScan *bt_scan = NULL;


static int handle_device_arrival(struct libusb_context *ctx, struct libusb_device *dev, libusb_hotplug_event event, void *user_data)
{
    int rc;

    struct hotplug_queue_entry *e = malloc(sizeof(struct hotplug_queue_entry));

    if ((rc = libusb_open(dev, &e->dev_handle)) != LIBUSB_SUCCESS)
    {
        fprintf(stderr, "error opening usb device (%s)\n", libusb_error_name(rc));
        free(e);
    }
    else
    {
        e->processed = false;
        TAILQ_INSERT_TAIL(&hpq, e, entries);
    }

    return 0;
}

static int handle_device_departure(struct libusb_context *ctx, struct libusb_device *dev, libusb_hotplug_event event, void *user_data)
{
    printf("DualShock controller (device %d on bus %d) disconnected!\n", libusb_get_device_address(dev),
                                                                         libusb_get_bus_number(dev));

    struct hotplug_queue_entry *e, *e_temp;
    struct libusb_device *e_dev;

    TAILQ_FOREACH_SAFE(e, &hpq, entries, e_temp)
    {
        e_dev = libusb_get_device(e->dev_handle);

        if (e_dev == dev) {
            TAILQ_REMOVE(&hpq, e, entries);
            libusb_close(e->dev_handle);
            free(e);
            break;
       }

    }

    return 0;
}

static bool register_usb_hotplug_callbacks(void)
{
    int rc;

    if (!libusb_has_capability(LIBUSB_CAP_HAS_HOTPLUG))
    {
        fprintf(stderr, "error: this libusb build does not have hotplugging capabilities\n");
        return false;
    }

    if ((rc = libusb_hotplug_register_callback(NULL, 
                                               LIBUSB_HOTPLUG_EVENT_DEVICE_ARRIVED, 
                                               0,
                                               DS_VENDOR_ID,
                                               DS_PRODUCT_ID,
                                               LIBUSB_HOTPLUG_MATCH_ANY,
                                               handle_device_arrival,
                                               NULL,
                                               &hp[0]
                                               )) != LIBUSB_SUCCESS)
    {
        fprintf(stderr, "error: failed to register hotplug callback 0 (%s)\n", libusb_error_name(rc));
        return false;
    }

    if ((rc = libusb_hotplug_register_callback(NULL, 
                                               LIBUSB_HOTPLUG_EVENT_DEVICE_LEFT, 
                                               0,
                                               DS_VENDOR_ID,
                                               DS_PRODUCT_ID,
                                               LIBUSB_HOTPLUG_MATCH_ANY,
                                               handle_device_departure,
                                               NULL,
                                               &hp[1]
                                               )) != LIBUSB_SUCCESS)
    {
        fprintf(stderr, "error: failed to register hotplug callback 1 (%s)\n", libusb_error_name(rc));
        return false;
    }

    return true;

}

static void handle_interrupt(int signal)
{
    printf("Interrupt signal caught. Exiting gracefully.\n");

    if (bt_scan)
    {
        [bt_scan stop];
    }

    run = false;
}

static bool perform_pairing_process(struct libusb_device_handle *dev_handle, const uint8_t *new_master)
{
    struct libusb_device *dev = libusb_get_device(dev_handle);
    uint8_t current_master[6] = {0};
    char current_master_str[18] = {0};
    char new_master_str[18] = {0};

    format_btaddr(new_master, new_master_str, 18);
    printf("Do you wish to pair DualShock controller (device %d on bus %d) to Bluetooth master %s?\n", 
                                                                                  libusb_get_device_address(dev),
                                                                                  libusb_get_bus_number(dev),
                                                                                  new_master_str);
    if (ds_get_master(dev_handle, current_master))
    {
        format_btaddr(current_master, current_master_str, 18);

        printf("Current master is: %s", current_master_str);

        if (memcmp(new_master, current_master, 6) == 0)
        {
            printf(" (this device)");
        }

        printf("\n");
    }

    if (cli_confirm()) 
    {
        if (!ds_set_master(dev_handle, new_master))
        {
            fprintf(stderr, "Error setting master device\n");
            return false;
        }
        else
        {
            printf("Successfully paired.\n");
        }
    }

    return true;
}

static void iobluetoothdevice_label_func(void *item, char **outbuf, size_t outbuflen)
{
    IOBluetoothDevice *device = (IOBluetoothDevice *) item;

    const char *address = [[device addressString] UTF8String];
    const char *name = [[device name] UTF8String];

    if (name)
    {
        snprintf(outbuf, outbuflen, "%s (\"%s\")", address, name);
    }
    else
    {
        snprintf(outbuf, outbuflen, "%s", address);
    }
}

static void empty_hotplug_queue(void)
{
    struct hotplug_queue_entry *e, *e_temp;

    TAILQ_FOREACH_SAFE(e, &hpq, entries, e_temp)
    {
        TAILQ_REMOVE(&hpq, e, entries);
        libusb_close(e->dev_handle);
        free(e);
    }
}

static bool init(void)
{
    if (signal(SIGINT, handle_interrupt))
    {
        return false;
    }

    TAILQ_INIT(&hpq);

    libusb_init(NULL);

    return true;
}

static bool cleanup(void)
{
    empty_hotplug_queue();
    libusb_exit(NULL);

    return true;
}

int main(int argc, char const *argv[])
{

    if (!init())
    {
        fprintf(stderr, "error: initialization failed\n");
        return 1;
    }

    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    bt_scan = [[BluetoothScan alloc] init];

    IOBluetoothDevice *device = NULL;

    do {
        [bt_scan start];

        if (!run)
        {
            [pool drain];
            cleanup();
            return 0;
        }

        NSArray *arr = [bt_scan foundDevices];
        IOBluetoothDevice **devices = (IOBluetoothDevice **) array_from_nsarray(arr);
        unsigned long num_devices = [arr count];

        printf("Select the desired master (or hit ENTER to scan again):\n");
        device = (IOBluetoothDevice *) cli_choice(devices, num_devices, iobluetoothdevice_label_func);

    } while (!device);

    uint8_t new_master[6];
    memcpy(new_master, [device getAddress]->data, 6);

    [pool drain];

    if (register_usb_hotplug_callbacks())
    {
        printf("Please connect your DualShock controller(s).\n");

        struct timeval timeout = {1, 0};
        struct hotplug_queue_entry *e, *e_temp;

        while (run)
        {
            libusb_handle_events_timeout(NULL, &timeout);

            TAILQ_FOREACH_SAFE(e, &hpq, entries, e_temp)
            {
                if (!e->processed)
                {
                    perform_pairing_process(e->dev_handle, new_master);
                    e->processed = true;
                }

            }
        }
    }

    cleanup();

    return 0;
}