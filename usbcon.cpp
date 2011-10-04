// g++ usbcon.cpp -L/usr/local/lib -lusb-1.0 -o usbcon

#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>
#include <stdio.h>
#include <string.h>

#include <libusb-1.0/libusb.h>

static void print_dev(libusb_device * dev)
{
    struct libusb_device_descriptor desc;
    int r = libusb_get_device_descriptor(dev, &desc);
    if(r < 0) {
        fprintf(stderr, "failed to get device descriptor");
        return;
    }
    printf("%04x:%04x (bus %d, device %d)\n",
        desc.idVendor, desc.idProduct,
        libusb_get_bus_number(dev), libusb_get_device_address(dev));
}

static libusb_device * find_lpc(libusb_device ** devs)
{
    for(libusb_device ** dev = devs; *dev != NULL; dev++)
    {
        struct libusb_device_descriptor desc;
        int r = libusb_get_device_descriptor(*dev, &desc);
        if(r < 0) {
            fprintf(stderr, "failed to get device descriptor");
            abort();
        }
        if(desc.idVendor == 0x1FC9 && desc.idProduct == 0x0003)
            return *dev;
    }
    return NULL;
}


int main(int argc, const char * argv[])
{
    libusb_device ** devs;
    int r = libusb_init(NULL);
    if(r < 0) {
        fprintf(stderr, "libusb_init() returned error %d\n", r);
        return r;
    }
    
    ssize_t cnt = libusb_get_device_list(NULL, &devs);
    if(cnt < 0) {
        fprintf(stderr, "libusb_get_device_list() returned error %d\n", r);
        return cnt;
    }
    
    // for(libusb_device ** dev = devs; *dev != NULL; dev++)
    //     print_dev(*dev);
    libusb_device * lpcdev = find_lpc(devs);
    if(lpcdev)
    {
        printf("Found device:\n");
        print_dev(lpcdev);
        
        libusb_device_handle * lpchand;
        r = libusb_open(lpcdev, &lpchand);
        if(r < 0) {
            fprintf(stderr, "libusb_open() returned error %d\n", r);
            exit(r);
        }
        
        r = libusb_set_configuration(lpchand, 1);
        if(r < 0) {
            fprintf(stderr, "libusb_set_configuration() returned error %d\n", r);
            libusb_close(lpchand);
            exit(r);
        }
        
        int interface = 1;
        
        r = libusb_claim_interface(lpchand, interface);
        if(r < 0) {
            fprintf(stderr, "libusb_claim_interface() returned error %d\n", r);
            libusb_close(lpchand);
            exit(r);
        }
        
        // uint8_t endpoint = 0x82;
        uint8_t endpoint = 0x02;
        uint8_t data[256];
        char * chdata = (char *)data;
        int length, actualLength;
        
        // data[0] = 100;
        strcpy(chdata, "USB MESSAGE     ");
        length = 16;
        r = libusb_bulk_transfer(lpchand, endpoint, data, length, &actualLength, 1000);
        if(r < 0) {
            fprintf(stderr, "libusb_bulk_transfer() returned error %d\n", r);
            libusb_release_interface(lpchand, interface);
            libusb_close(lpchand);
            exit(r);
        }
        fprintf(stderr, "libusb_bulk_transfer() returned %d\n", r);
        printf("Bytes transferred: %d\n", actualLength);
        
        r = libusb_release_interface(lpchand, interface);
        if(r < 0) {
            fprintf(stderr, "libusb_release_interface() returned error %d\n", r);
            libusb_close(lpchand);
            exit(r);
        }
        
        libusb_close(lpchand);
    }
    else
    {
        printf("Device not found\n");
    }
    
    libusb_free_device_list(devs, 1);
    libusb_exit(NULL);
    
    return EXIT_SUCCESS;
}

