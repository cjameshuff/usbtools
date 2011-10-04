#!/usr/bin/env ruby

require 'libusb'
require 'pp'

LIBUSB_REQUEST_TYPE_STANDARD = (0x00<< 5),
LIBUSB_REQUEST_TYPE_CLASS = (0x01 << 5),
LIBUSB_REQUEST_TYPE_VENDOR = (0x02 << 5)
LIBUSB_REQUEST_TYPE_RESERVED = (0x03 << 5)

usb = LIBUSB::Context.new
# device.configuration = 1

def configure_usb(device, conf)
    device.open {|h| h.configuration = conf}
end
def read_usb(device, len)
    data = "\0"*len
    device.open {|h|
        h.detach_kernel_driver(1)
        h.claim_interface(1)
        h.bulk_transfer(:endpoint => 0x82, :dataIn => data)
        h.release_interface(1)
    }
end

def write_usb(device, data)
    device.open {|h|
        h.claim_interface(1)
        h.bulk_transfer(:endpoint => 0x02, :dataOut => data)
        h.release_interface(1)
    }
end
device = usb.devices(:idVendor => 0x1FC9, :idProduct => 0x0003).first
# pp device.interfaces
puts device.inspect
puts "idVendor: \"#{device.idVendor.to_s(16)}\""
puts "idProduct: \"#{device.idProduct.to_s(16)}\""
puts "product: \"#{device.product}\""
puts "manufacturer: \"#{device.manufacturer}\""
# configure_usb(device, 1)
# write_usb(device, 10.chr)

device.open {|h|
    # (1..16).each {|i|
        # puts i
    h.configuration = 1
        # sleep(1)
    h.claim_interface(1)
        # h.bulk_transfer(:endpoint => 0x02, :dataOut => 10.chr)
        h.bulk_transfer(:endpoint => 0x02, :dataOut => "USB MESSAGE     ")
    h.release_interface(1)
    # }
}

# pp device
# USB.devices.each {|dev|
#     begin
#         pp dev
#         puts "idVendor: \"#{dev.idVendor}\""
#         puts "idProduct: \"#{dev.idProduct}\""
#         puts "product: \"#{dev.product}\""
#         puts "manufacturer: \"#{dev.manufacturer}\""
#         puts
#     rescue
#     end
# }