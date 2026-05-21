# Exercise 08 — Configure a secondary IPv4 address

**Target:** `server2`  
**Reference:** EX200 sample Q1 (networking variant)

## Task

Configure the **second** network interface on **server2** (device **`eth2`**) with:

| Parameter | Value |
|-----------|--------|
| IPv4 address | **192.168.55.175/24** |
| Gateway | **192.168.55.1** |
| DNS | **8.8.8.8** |
| Method | **manual** (static) |
| Connection | Must activate **automatically** on boot |

Do **not** change the primary lab address on **`eth1`** (`192.168.55.151/24`).

Verify with `ip -4 addr show eth2` and `nmcli`.

When finished: `./scripts/lab-practice.sh validate 08`
