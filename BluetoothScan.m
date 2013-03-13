/* -*- mode: objective-c; tab-width: 4; indent-tabs-mode: nil; encoding: utf-8 -*- */

#import "BluetoothScan.h"
#import <stdio.h>
#import <CoreFoundation/CFRunLoop.h>
#import <IOBluetooth/objc/IOBluetoothDevice.h>

@implementation BluetoothScan

- (id) init 
{

    if (self = [super init])
    {
        inquiry = [IOBluetoothDeviceInquiry inquiryWithDelegate:self];
        completed = false;
    }

    return self;

}

- (void) deviceInquiryStarted:(IOBluetoothDeviceInquiry *)sender 
{
    printf("Scanning for bluetooth devices...\n");
}

- (void) deviceInquiryDeviceFound:(IOBluetoothDeviceInquiry *)sender device:(IOBluetoothDevice *)device
{
    printf("Found device %s\n", [[device addressString] UTF8String]);
}

- (void) deviceInquiryComplete:(IOBluetoothDeviceInquiry *)sender error:(IOReturn)error aborted:(BOOL)aborted
{
    if (aborted && !completed)
    {
        fprintf(stderr, "Scan aborted.\n");
    }
    else if (!completed)
    {
        printf("Scan complete.\n");
    }
    CFRunLoopStop(CFRunLoopGetCurrent());
    completed = true;
}

- (void) start
{
    [inquiry start];

    CFRunLoopRun();
}

- (void) stop
{
    [inquiry stop];
}

- (NSArray *) foundDevices
{
    return [inquiry foundDevices];
}

@end