# Tutorial: Setup VPN on Digital Ocean

[REF: Digital Ocean CLI](https://github.com/digitalocean/doctl)
```
doctl -v compute ssh-key import terraform --public-key-file ~/.ssh/id_rsa.pub
doctl -v compute ssh-key list

doctl compute region list
doctl compute image list-distribution --public

>>53871280    19.10 x64            snapshot    Ubuntu           ubuntu-19-10-x64        true      20

doctl compute droplet list --format "ID,Name,PublicIPv4"
```

[REF: Digital Ocean provider](https://www.terraform.io/docs/providers/do/index.html)


## setup VPN
https://sysadmin.pm/wireguard/
https://angristan.xyz/how-to-setup-vpn-server-wireguard-nat-ipv6/
