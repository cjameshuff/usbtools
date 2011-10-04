#!/usr/bin/env ruby

load('genusbdesc.rb')

devdesc = Descriptor.new(USB_DEVICE_DESCRIPTOR) {
    bcdUSB 0x0200
    bDeviceClass 0xFF
    bDeviceSubClass 0xFE
    bDeviceProtocol 0x00
    bMaxPacketSize0 64
    idVendor NXP_VID
    idProduct 0x0003
    bcdDevice 0x0100
    iManufacturer 1
    iProduct 2
    iSerialNumber 3
    bNumConfigurations 1
}

confdesc = Descriptor.new(USB_CONFIGURATION_DESCRIPTOR) {
    bNumInterfaces  2
    bConfigurationValue  1
    iConfiguration  0x00
    bmAttributes  USB_CONFIG_BUS_POWERED
    bMaxPower  100/2 # FIXME
    
    append Descriptor.new(USB_INTERFACE_DESCRIPTOR) {
        bInterfaceNumber 0
        bAlternateSetting 0x00
        bNumEndpoints 1
        bInterfaceClass 0xFE
        bInterfaceSubClass 0x00
        bInterfaceProtocol 0x00
        iInterface 0x5E
    }
    append Descriptor.new(USB_ENDPOINT_DESCRIPTOR) {
        bEndpointAddress 0x81# IN
        bmAttributes USB_ENDPOINT_TYPE_INTERRUPT
        wMaxPacketSize 16
        bInterval 2
    }
    append Descriptor.new(USB_INTERFACE_DESCRIPTOR) {
        bInterfaceNumber 1
        bAlternateSetting 0x00
        bNumEndpoints 2
        bInterfaceClass 0xFE
        bInterfaceSubClass 0x00
        bInterfaceProtocol 0x00
        iInterface 0x5E
    }
    append Descriptor.new(USB_ENDPOINT_DESCRIPTOR) {
        bEndpointAddress 0x02# OUT
        bmAttributes USB_ENDPOINT_TYPE_BULK
        wMaxPacketSize 64
        bInterval 0
    }
    append Descriptor.new(USB_ENDPOINT_DESCRIPTOR) {
        bEndpointAddress 0x82# IN
        bmAttributes USB_ENDPOINT_TYPE_BULK
        wMaxPacketSize 64
        bInterval 0
    }
}

strdesc = Descriptor.new(USB_STRING_DESCRIPTORS) {
    wLANGID 0x0409 # wLANGID FIXME
    append Descriptor.new(USB_STRING_DESCRIPTOR) {bString "NXP SEMICOND "}
    append Descriptor.new(USB_STRING_DESCRIPTOR) {bString "NXP LPC13XX CHIP "}
    append Descriptor.new(USB_STRING_DESCRIPTOR) {bString "DEMO00000000"}
    append Descriptor.new(USB_STRING_DESCRIPTOR) {bString "CHIP"}
    append Descriptor.new(USB_STRING_DESCRIPTOR) {bString "COM/DATA"}
}

puts devdesc.to_s
puts
puts "const uint8_t USB_DeviceDescriptor[] = {"
puts devdesc.to_hex
puts "};"
puts
puts confdesc.to_s
puts
puts "const uint8_t USB_ConfigDescriptor[] = {"
puts confdesc.to_hex
puts "};"
puts
puts strdesc.to_s
puts
puts "const uint8_t USB_StringDescriptor[] = {"
puts strdesc.to_hex
puts "};"

