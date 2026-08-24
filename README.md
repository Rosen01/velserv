# velserv
A TCP to Velbus gateway for Linux.

For use with the http://www.velbus.eu range of digital building control hardware.

This TCP server offers a way to share the USB connection so that various software platforms connect to the Velbus network simultaneously.
For example, [VelbusLink](www.velbus.eu/downloads), [OpenHab](www.openhab.org), [Home Assistant](www.home-assistant.io)...

Based on [velserv by jeroends](https://github.com/jeroends/velserv).

# Docker container
The code used in this container is based on the repository [HA-velserv from StefCoene](https://github.com/StefCoene/HA-velserv/).

## Device
Use the /dev/serial/by-id/ path instead of /dev/ttyACM* — this path stays stable when the device is reconnected or the system reboots.
```
/dev/serial/by-id/usb-Velleman_Projects_VMB1USB_Velbus_USB_interface-if00
```

## Port
Port 3788/tcp is exposed.

## Environment variables
Some variables can be passed to the container to configure the way it runs.
| Variable     | Description                                  | Supported values               | Default value |
|--------------|----------------------------------------------|--------------------------------|---------------|
| TZ           | Timezone                                     | [TZ values](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones)                      | host config   |
| LOG_DISABLE  | Disable logging                              | true, false                    | true          |
| LOG_LEVEL    | If logging is enabled, set the logging level | debug, debug_com, debug_socket | debug         |
| VELSERV_MODE | The running mode of VelServ                  | gateway, server, client        | gateway       |

## Docker CLI example
```
docker pull rosen01/velserv:latest
docker run -p 3788:3788 --device=/dev/serial/by-id/usb-Velleman_Projects_VMB1USB_Velbus_USB_interface-if00:/dev/ttyACM0 -e "TZ=Europe/Brussels" -d velserv:latest
```

## Docker compose example
```
services:
  velserv:
    container_name: velserv
    image: "rosen01/velserv:latest"
    restart: unless-stopped
    devices:
      - /dev/serial/by-id/usb-Velleman_Projects_VMB1USB_Velbus_USB_interface-if00:/dev/ttyACM0
    ports:
      - 3788:3788
    environment:
      - TZ=Europe/Brussels
      - LOG_DISABLE=true      # true / false (default=true)
      - LOG_LEVEL=debug       # debug / debug_com / debug_socket (default=debug)
      - VELSERV_MODE=gateway  # gateway / server / client (default=gateway)
    tty: true
```