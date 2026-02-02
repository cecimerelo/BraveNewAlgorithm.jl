use lib qw(lib ../lib); # mode: -*- cperl -*-

use strict;
use warnings;

use Test::More;

use Utils qw(process_sensors_output);

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

  my $temperature = process_sensors_output( $t );

  ok( $temperature, "Something is extracted: $temperature");
  like( $temperature, qr/^\d+\.\d+$/, "$temperature looks like a temperature");
}

done_testing();
