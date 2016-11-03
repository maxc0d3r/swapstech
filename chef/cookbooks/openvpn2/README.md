_NOTE_: This cookbook is currently under development and it not ready for production use.

# openvpn2 cookbook

Open VPN cookbook to install and configure OpenVPN

## Testing

### Local

```sh
$ kitchen test
```

### Acceptance (cloud)

```sh
$ make setup_aws
$ KITCHEN_YAML=".kitchen.cloud.yml" kitchen test
$ make teardown_aws
```
