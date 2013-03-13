.PHONY: all

all: deps
	gcc -I./vendor/libusb/libusb -I./vendor/sglib -framework Foundation -framework CoreFoundation -framework IOBluetooth -framework IOKit -o dualpair ./vendor/libusb/libusb/.libs/libusb-1.0.a aux.m cli.m BluetoothScan.m hid.m dualshock.m dualpair.m

deps:
	make -C vendor/libusb

clean:
	make -C vendor/libusb clean
	@rm -f dualpair *.o
	
