# Knitted Capacitive Touch Sensor Maker Kit v1.0
This is a repository containing hardware and software source files and documentation for the Knitted Capacitive Touch Sensor (CTS) Maker Kit created by the [Pennsylvania Fabric Discovery Center](https://drexel.edu/functional-fabrics/initiatives/pennsylvania-fabric-discovery-center/).

## How to use this documentation
This documentation is a reference for the construction, application, and maintenance of the CTS hardware and software.

## Project contents
* __hardware__ - [Autodesk EAGLE](https://www.autodesk.com/products/eagle/overview) schematic (.sch) and board (.brd) files used to create the CTS PCB. This folder also contains a bill of materials (BOM) with descriptions of components.
* __firmware__ - Firmware flashed to the [PJRC Teensy 2.0](https://www.pjrc.com/store/teensy_pins.html) microcontroller included on the v1.0 maker kit sensing boards.
* __src__ - Source files for the CTS I2C library used to interface one or more sensor boards to an I2C-enabled Arduino-compatible microcontroller.
* __docs__ - Additional information related to hardware or software documentation.
* __apps__ - Demonstration applications created using the [Processing IDE](https://www.processing.org).

## Getting Started

### What's included in the Maker Kit?
The CTS Maker Kit v1.0 includes the following items:
* (1) Teensy 2.0 microcontroller
* (1) CTS PCB
* (1) Alligator to Molex connector
* (1) Knitted touchpad
* (1) USB type A to mini type B cable
* (1) Insert describing the CTS and containing a link to this GitHub project page.

### Connecting to a PC
The CTS connects to and is powered over USB. The device will mount as a USB serial port (e.g. `COM##` in Microsoft Windows, `/dev/cu.usbmodem#####` in Mac OSX, or `/dev/ttyUSB#` in Ubuntu Linux). You may use the Arduino IDE to monitor serial output by selecting `Tools > Serial Monitor`.

### Connecting to fabric
The alligator clips on the CTS module clip onto the button snaps affixed to the knitted touchpad. The clips can be removed from the PCB via the 3-pin, 0.1" pitch Molex connector. Users may create their own connectors to interface with the PCB using the following Molex [crimps](https://www.taydaelectronics.com/crimp-terminal-connector-3-96mm.html) and [housings](https://www.taydaelectronics.com/housing-connector-2-54mm-3-pins.html).

### Connecting with other CTS modules
The CTS contains breakouts for a 4-pin I2C connector. By default, each sensor board responds as a slave I2C device with address 0x01. The sensor boards can be connected individually to a host microcontroller or daisy-chained to report data from multiple toucpads. __Note:__ Version 1.0 CTS sensor boards must be re-flashed with a different I2C address to respond over the same bus.

The pinout of the I2C breakout is compatible with the [Sparkfun Qwiic I2C adapter](https://www.sparkfun.com/products/14495) with the exception that the voltage output of the sensor is __+5V__ and __not +3.3V__.

## Modifying the hardware
Schematic (.sch) and board layout (.brd) files are located in the __hardware__ folder.

### Extending the firmware
Further information can be found in the [ATmega 32U4 datasheet](http://ww1.microchip.com/downloads/en/devicedoc/atmel-7766-8-bit-avr-atmega16u4-32u4_datasheet.pdf).
