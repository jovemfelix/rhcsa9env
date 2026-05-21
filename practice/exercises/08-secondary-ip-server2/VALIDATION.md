# Validação — Exercise 08

## Critérios

- `eth2` tem `192.168.55.175/24`
- `eth1` mantém `192.168.55.151/24`
- Ligação NM em modo manual para eth2

## nmcli (exemplo)

```bash
nmcli con show
# identifica connection de eth2
nmcli con mod "<conn-eth2>" ipv4.addresses 192.168.55.175/24 \
  ipv4.gateway 192.168.55.1 ipv4.dns 8.8.8.8 ipv4.method manual
nmcli con up "<conn-eth2>"
```

## Se falhar

- Nome da connection pode ser `eth2` ou `Wired connection 2` — usa `nmcli -t -f NAME,DEVICE con show`.
