# lnx-graceful-shutdown
WireGuard monitoring service for Linux (Debian-based).
The primary purpose is to check the WireGuard connection. If the remote server changes its IP address, WireGuard won't reconnect because it only knows the original host used for the initial connection.

The `wireguard-monitor` service pings the monitored resource, and if it goes down, the script restarts the wg-quick@wg0 service.

## Usage

replace 10.10.10.1 by internal WireGuard peer ip

replace 5 by time in minutes to initiate restart (example: 1 or 10 or ...) 

```shell
./install.sh 10.10.10.1 5
```