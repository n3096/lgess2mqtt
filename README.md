# LG ESS Solar 2 MQTT (for e.g. Home Assistant)
This project provides a docker-container to read out data of LG ESS Home devices and communicate this with an MQTT broker - e.g. in an environment with **Home Assistant Container**.
If you have installed **Home Assistant Operating System**, you can simply use 3rd-party add-on integration like [Buktahula/hassio-addons/LG_ESS](https://github.com/Buktahula/hassio-addons/tree/main/LG_ESS).

## Table of contents
[Sources](#sources)\
[Preparations](#preparations)\
&emsp;[1. Fetch the LG ESS password](#1-fetch-the-lg-ess-password)\
&emsp;[2. Install and configure an MQTT broker for e.g. Home Assistant:](#2-install-and-configure-an-mqtt-broker-for-eg-home-assistant)\
[Run as a docker container](#run-as-a-docker-container)\
&emsp;[Example full docker-compose](#example-full-docker-compose)\
[Home Assistant integration configuration](#home-assistant-integration-configuration)\
&emsp;[Configure hass_autoconfig_sensors](#configure-hassautoconfigsensors)\
&emsp;[Full configuration file example](#full-configuration-file-example)\
[Sensor (Home Assistant entity integration)](#sensor--home-assistant-entity-integration-)

## Sources
Python library for LG ESS Solar power converters with EnerVU app compatibility
from [gluap/pyess](https://github.com/gluap/pyess) in a Docker Container for Home Assistant.

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

Also, this repository is initially highly inspired by the LG_ESS plugin of [Buktahula/hassio-addons](https://github.com/Buktahula/hassio-addons/tree/main/LG_ESS).

## Preparations

### 1. Fetch the LG ESS password
1. Install Python on a Wi-Fi capable device\
Android: Install Pydroid 3 ([Play Store](https://play.google.com/store/apps/details?id=ru.iiec.pydroid3))\ 
Windows/ Max/ Linux: See ([official Python docs](https://wiki.python.org/moin/BeginnersGuide/Download))
2. Connect to the LG ESS Wi-Fi to fetch the device's password
3. Being in that Wi-Fi, open Python's **Terminal** (not _Interpreter_) and run these commands\
   `pip install pyess`\
   `esscli --action get_password`
4. Note down the LG ESS password, which you will find after the terminal response `INFO:pyess.cli:password: `

### 2. Install and configure an MQTT broker for e.g. Home Assistant
For Docker, you may use [eclipse-mosquitto](https://hub.docker.com/_/eclipse-mosquitto).

### 3. Initial configuration
You need to provide a configuration file on _/etc/lgess2mqtt.conf_ to make this service run. 
Initially, you have to set all the following configuration properties.

```
ess_password = <your_ess_password>
mqtt_server = <your_mqtt_server>
mqtt_user = <your_mqtt_username>
mqtt_password = <your_mqtt_password>
```

## Run as a docker container
To ensure this docker container will run, you need to create the `essmqtt.conf` file shown above in [Initial Configuration](#3-initial-configuration) and mount it by the docker `volumes` mechanism.

### Example full docker-compose
```
version: '3.9'
services:
  lgess2mqtt:
    image: n3096/lgess2mqtt:latest
    container_name: lgess2mqtt
    restart: always
    depends_on:
      - mqtt-broker
    network_mode: host
    volumes:
      - /my/local/path/essmqtt.conf:/etc/essmqtt.conf:ro

  mqtt-broker:
    image: eclipse-mosquitto:latest
    container_name: mqtt-broker
    restart: unless-stopped
    ports:
      - '1883:1883'
      - '9001:9001'
    volumes:
      - /my/local/path/mqtt.conf:/mosquitto/config/mosquitto.conf
      - /my/local/path/data/:/mosquitto/data/
      - /my/local/path/log/:/mosquitto/log/
```

## Home Assistant integration configuration
You can find all configuration options in [gluap/pyess#essmqtt-config-file](https://github.com/gluap/pyess#essmqtt-config-file).
The following will show concrete examples.

### Configure hass_autoconfig_sensors
This docker container and the MQTT-Broker should be running to look for the topic names.

All data, gathered from the LG ESS, is sent in the main topic "ess". By default, Home Assistant reads from the main topic "homeassistant", wherefore you should set the `hass_autoconfig_sensors` value. This will link the topic "homeassistant/sensor/esshomestatisticsbat_use" to the origin topic "ess/home/statistics/bat_use".
Finding out the possible data topics, you can use e.g. [MQTT Explorer Page](https://mqtt-explorer.com/), connect to your MQTT-Broker. Depending on the configuration, the data can be delayed up to the value of `interval_seconds` (default 10 seconds). You see all available topics, which may look similar to this:


![MQTT-Explorer topic example](/documentation-media/mqtt-explorer-topic-example.png)

### Full configuration file example
The topics names may vary considerably. Therefore, this is just an example. In the prior step [Configure hass_autoconfig_sensors](#configure-hassautoconfigsensors) you can find your provided topic names.
```
ess_password = myEssPassword
mqtt_server = 127.0.0.1
mqtt_user = myMqttUser
mqtt_password = myMqttPassw0rd
# optional settings
## sensors for homeassistant MQTT discovery (default is not set -> homeassistant autoconfig disabled)
hass_autoconfig_sensors = ess/home/statistics/pcs_pv_total_power,ess/home/statistics/batconv_power,ess/home/statistics/bat_use,ess/home/statistics/bat_status,ess/home/statistics/bat_user_soc,ess/home/statistics/load_power,ess/home/statistics/ac_output_power,ess/home/statistics/load_today,ess/home/statistics/grid_power,ess/home/statistics/current_day_self_consumption,ess/home/statistics/current_pv_generation_sum,ess/home/statistics/current_grid_feed_in_energy,ess/home/direction/is_direct_consuming_,ess/home/direction/is_battery_charging_,ess/home/direction/is_battery_discharging_,ess/home/direction/is_grid_selling_,ess/home/direction/is_grid_buying_,ess/home/direction/is_charging_from_grid_,ess/home/direction/is_discharging_to_grid_,ess/home/operation/status,ess/home/operation/mode,ess/home/operation/pcs_standbymode,ess/home/operation/drm_mode0,ess/home/operation/remote_mode,ess/home/operation/drm_control,ess/home/wintermode/winter_status,ess/home/wintermode/backup_status,ess/home/pcs_fault/pcs_status,ess/home/pcs_fault/pcs_op_status,ess/home/heatpump/heatpump_protocol,ess/home/heatpump/heatpump_activate,ess/home/heatpump/current_temp,ess/home/heatpump/heatpump_working,ess/home/evcharger/ev_activate,ess/home/evcharger/ev_power,ess/home/gridWaitingTime,ess/common/PV/brand,ess/common/PV/capacity,ess/common/PV/pv1_voltage,ess/common/PV/pv2_voltage,ess/common/PV/pv3_voltage,ess/common/PV/pv1_power,ess/common/PV/pv2_power,ess/common/PV/pv3_power,ess/common/PV/pv1_current,ess/common/PV/pv2_current,ess/common/PV/pv3_current,ess/common/PV/today_pv_generation_sum,ess/common/PV/today_month_pv_generation_sum,ess/common/BATT/status,ess/common/BATT/soc,ess/common/BATT/dc_power,ess/common/BATT/winter_setting,ess/common/BATT/winter_status,ess/common/BATT/safety_soc,ess/common/BATT/backup_setting,ess/common/BATT/backup_status,ess/common/BATT/backup_soc,ess/common/BATT/today_batt_discharge_enery,ess/common/BATT/today_batt_charge_energy,ess/common/BATT/month_batt_charge_energy,ess/common/BATT/month_batt_discharge_energy,ess/common/GRID/active_power,ess/common/GRID/a_phase,ess/common/GRID/freq,ess/common/GRID/today_grid_feed_in_energy,ess/common/GRID/today_grid_power_purchase_energy,ess/common/GRID/month_grid_feed_in_energy,ess/common/GRID/month_grid_power_purchase_energy,ess/common/LOAD/load_power,ess/common/LOAD/today_load_consumption_sum,ess/common/LOAD/today_pv_direct_consumption_enegy,ess/common/LOAD/today_batt_discharge_enery,ess/common/LOAD/today_grid_power_purchase_energy,ess/common/LOAD/month_load_consumption_sum,ess/common/LOAD/month_pv_direct_consumption_energy,ess/common/LOAD/month_batt_discharge_energy,ess/common/LOAD/month_grid_power_purchase_energy,ess/common/PCS/today_self_consumption,ess/common/PCS/month_co2_reduction_accum,ess/common/PCS/today_pv_generation_sum,ess/common/PCS/month_pv_generation_sum,ess/common/PCS/today_grid_feed_in_energy,ess/common/PCS/month_grid_feed_in_energy,ess/common/PCS/pcs_stauts,ess/common/PCS/feed_in_limitation,ess/common/PCS/operation_mode
## update interval for MQTT values in seconds (default is 10 seconds)
# interval_seconds = 10
## only send the values below common every n'th update of those for home
## this is a debugging option that shouldn't be required, (default is 1)
# common_divisor = 1
```

## Sensor (Home Assistant entity integration)
Here you can find a german example for the sensor configuration in Home Assistant Energy Dashboard: [/configurations/sensor.yaml](https://github.com/n3096/lgess2mqtt/blob/main/configurations/sensor.yaml) (copy of [Buktahuala/hassio-addons](https://github.com/Buktahula/hassio-addons/tree/main/LG_ESS/sensor.yaml))
