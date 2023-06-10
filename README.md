# LG ESS Solar 2 MQTT for e.g. Home Assistant

This project provides a docker-container to read out data of LG ESS Home devices and communicate this with a MQTT instance - e.g. in an environment with **Home Assistant Container**.
If you have installed **Home Assistant Operating System**, you can simply use 3rd-party add-ons like [hassio-addons/LG_ESS](https://github.com/Buktahula/hassio-addons/tree/main/LG_ESS).

## Sources

Python library for LG ESS Solar power converters with EnerVU app compatibility
from https://github.com/gluap/pyess in a Docker Container for Home Assistant.

Copyright (c) 2019-2020 Paul Görgen

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

Also, this repository is highly inspired by https://github.com/Buktahula/hassio-addons/tree/main/LG_ESS.

## Requirements

### Fetch the device password
1. Install Python
 * Android: Install Pydroid 3 ( https://play.google.com/store/apps/details?id=ru.iiec.pydroid3 ) 
 * Windows/ Max/ Linux: See https://wiki.python.org/moin/BeginnersGuide/Download
2. Connect to the LG ESS Wi-Fi to fetch the device's password
3. Being in that Wi-Fi open Python's **Terminal** (not Interpreter) and run these commands

   `pip install pyess`

   `esscli --action get_password`

4. Note down the ESS password after the terminal response `INFO:pyess.cli:password: `

### Install and configure MQTT broker for e.g. Home Assistant:
https://hub.docker.com/_/eclipse-mosquitto

### Configuration File

You need to provide a configuration file on _/etc/lgess2mqtt.conf_ to make this service run.
```
ess_password = <your_ess_password>
mqtt_server = <your_mqtt_server>
mqtt_user = <your_mqtt_username>
mqtt_password = <your_mqtt_password>
# optional settings
## sensors for homeassistant MQTT discovery (default is not set -> homeassistant autoconfig disabled)
# hass_autoconfig_sensors = ess/common/BATT/soc,ess/home/statistics/pcs_pv_total_power,ess/common/GRID/active_power,ess/common/LOAD/load_power
## update interval for MQTT values in seconds (default is 10 seconds)
# interval_seconds = 10
## only send the values below common every n'th update of those for home
## this is a debugging option that shouldn't be required, (default is 1)
# common_divisor = 1
```

## Run the docker container
tbd

## Sensor (Home Assistant)
Here you can find a german example for the sensor configuration in Home Assistant Energy Dashboard: [/sensor.yaml](https://github.com/n3096/lgess2mqtt/blob/main/sensor.yaml) (copy of [Buktahuala/hassio-addons](https://github.com/Buktahula/hassio-addons/tree/main/LG_ESS/sensor.yaml))
