use lib qw(lib ../lib); # mode: -*- cperl -*-

use strict;
use warnings;

use Test::More;

use Utils qw(process_sensors_output process_sensors_output_intel);

my $output =<<EOC;
mt7925_phy0-pci-0700
Adapter: PCI adapter
temp1:        +35.0°C  

spd5118-i2c-1-52
Adapter: SMBus PIIX4 adapter port 0 at 0b00
temp1:        +31.0°C  (low  =  +0.0°C, high = +55.0°C)
                       (crit low =  +0.0°C, crit = +85.0°C)

spd5118-i2c-1-51
Adapter: SMBus PIIX4 adapter port 0 at 0b00
temp1:        +30.2°C  (low  =  +0.0°C, high = +55.0°C)
                       (crit low =  +0.0°C, crit = +85.0°C)

k10temp-pci-00c3
Adapter: PCI adapter
Tctl:         +38.5°C  
Tccd1:        +34.0°C  
Tccd2:        +28.4°C  

r8169_0_600:00-mdio-0
Adapter: MDIO adapter
temp1:        +43.5°C  (high = +120.0°C)

spd5118-i2c-1-53
Adapter: SMBus PIIX4 adapter port 0 at 0b00
temp1:        +29.8°C  (low  =  +0.0°C, high = +55.0°C)
                       (crit low =  +0.0°C, crit = +85.0°C)

spd5118-i2c-1-50
Adapter: SMBus PIIX4 adapter port 0 at 0b00
temp1:        +30.0°C  (low  =  +0.0°C, high = +55.0°C)
                       (crit low =  +0.0°C, crit = +85.0°C)

nvme-pci-0200
Adapter: PCI adapter
Composite:    +35.9°C  (low  = -273.1°C, high = +81.8°C)
                       (crit = +84.8°C)
Sensor 1:     +35.9°C  (low  = -273.1°C, high = +65261.8°C)
Sensor 2:     +37.9°C  (low  = -273.1°C, high = +65261.8°C)
EOC

my $output2 =<<EOC;
mt7925_phy0-pci-0700
Adapter: PCI adapter
temp1:        +36.0°C  

spd5118-i2c-1-52
Adapter: SMBus PIIX4 adapter port 0 at 0b00
temp1:        +31.0°C  (low  =  +0.0°C, high = +55.0°C)
                       (crit low =  +0.0°C, crit = +85.0°C)

spd5118-i2c-1-51
Adapter: SMBus PIIX4 adapter port 0 at 0b00
temp1:        +30.2°C  (low  =  +0.0°C, high = +55.0°C)
                       (crit low =  +0.0°C, crit = +85.0°C)

k10temp-pci-00c3
Adapter: PCI adapter
Tctl:         +39.9°C  
Tccd1:        +28.6°C  
Tccd2:        +28.1°C  

r8169_0_600:00-mdio-0
Adapter: MDIO adapter
temp1:        +42.5°C  (high = +120.0°C)

spd5118-i2c-1-53
Adapter: SMBus PIIX4 adapter port 0 at 0b00
temp1:        +30.0°C  (low  =  +0.0°C, high = +55.0°C)
                       (crit low =  +0.0°C, crit = +85.0°C)

spd5118-i2c-1-50
Adapter: SMBus PIIX4 adapter port 0 at 0b00
temp1:        +30.0°C  (low  =  +0.0°C, high = +55.0°C)
                       (crit low =  +0.0°C, crit = +85.0°C)

nvme-pci-0200
Adapter: PCI adapter
Composite:    +35.9°C  (low  = -273.1°C, high = +81.8°C)
                       (crit = +84.8°C)
Sensor 1:     +35.9°C  (low  = -273.1°C, high = +65261.8°C)
Sensor 2:     +37.9°C  (low  = -273.1°C, high = +65261.8°C)
EOC

for my $t ($output, $output2) {

  my @temperatures = process_sensors_output( $t );

  is( $#temperatures , 1, "Extracted two temperatures @temperatures" );
  for my $temp (@temperatures) {
    ok( $temp, "Something is extracted: $temp");
    like( $temp, qr/^\d+\.\d+$/, "$temp looks like a temperature");
  }
}

my $output_intel =<<EOC;
iwlwifi_1-virtual-0
Adapter: Virtual device
temp1:        +40.0°C

pch_cannonlake-virtual-0
Adapter: Virtual device
temp1:        +43.0°C

ucsi_source_psy_USBC000:001-isa-0000
Adapter: ISA adapter
in0:           0.00 V  (min =  +0.00 V, max =  +0.00 V)
curr1:         0.00 A  (max =  +0.00 A)

BAT0-acpi-0
Adapter: ACPI interface
in0:          17.06 V

coretemp-isa-0000
Adapter: ISA adapter
Package id 0:  +45.0°C  (high = +100.0°C, crit = +100.0°C)
Core 0:        +44.0°C  (high = +100.0°C, crit = +100.0°C)
Core 1:        +44.0°C  (high = +100.0°C, crit = +100.0°C)
Core 2:        +45.0°C  (high = +100.0°C, crit = +100.0°C)
Core 3:        +45.0°C  (high = +100.0°C, crit = +100.0°C)

thinkpad-isa-0000
Adapter: ISA adapter
fan1:           0 RPM
CPU:          +44.0°C  
GPU:              N/A  
temp3:        +37.0°C  
temp4:         +0.0°C  
temp5:        +40.0°C  
temp6:        +44.0°C  
temp7:        +44.0°C  
temp8:            N/A  

ucsi_source_psy_USBC000:002-isa-0000
Adapter: ISA adapter
in0:           5.00 V  (min =  +5.00 V, max = +13.20 V)
curr1:         3.00 A  (max =  +3.21 A)

nvme-pci-0300
Adapter: PCI adapter
Composite:    +38.9°C  (low  = -273.1°C, high = +83.8°C)
                       (crit = +84.8°C)
Sensor 1:     +38.9°C  (low  = -273.1°C, high = +65261.8°C)
Sensor 2:     +31.9°C  (low  = -273.1°C, high = +65261.8°C)

acpitz-acpi-0
Adapter: ACPI interface
temp1:        +44.0°C  
EOC

my $temperature = process_sensors_output_intel( $output_intel);
ok( $temperature, "Something is extracted: $temperature");
like( $temperature, qr/^\d+\.\d+$/, "$temperature looks like a temperature");

done_testing();
