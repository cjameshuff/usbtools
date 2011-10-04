genusbdesc.rb is a library for generating USB descriptors from a description with a simple and readable syntax, automatically handling things like computing sizes and splitting up strings. An example of its use is in examples/lpcusbdesc.rb.

There is a single `Descriptor` class that takes a descriptor type and a block in which the descriptor fields can be set. An error will be produced if an attempt is made to set a field that doesn't exist, and the size and type fields are set automatically. Order does not matter, the order in the `fields` hash of the descriptor type is always used. There are currently no default values, all fields other than bLength, wTotalLength, and bDescriptorType must be specified.

usbcon.cpp and usbcon.rb are just starting points for working with libusb.