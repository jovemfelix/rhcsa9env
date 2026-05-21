# Lab context (nine.example.com)

Use this mapping when a sample exam uses other names (e.g. `node1.domain250.example.com`).

| Sample exam (RHCSA-EX200 repo) | This lab |
|--------------------------------|----------|
| `foundation0.ilt.example.com` / DVD HTTP | `http://repo/BaseOS` and `http://repo/AppStream` |
| `node1` / Server-A | **server1** — `192.168.55.150` |
| `node2` / Server-B | **server2** — `192.168.55.151` |
| `172.25.250.0/24` | `192.168.55.0/24` (gateway lab: `192.168.55.1`) |
| Extra NIC on node2 | **server2** `eth2` / `eth3` — `192.168.55.175`, `192.168.55.176` |
| Extra disks | **server2** `/dev/vdb`, `/dev/vdc` → `/extradisk1`, `/extradisk2` |

## Access

```bash
vagrant ssh server1
vagrant ssh server2
vagrant ssh repo
```

Root on guests: `sudo su -` (password `password` after lab provision).

## Baseline after provision

- **server1 / server2:** `/etc/yum.repos.d` empty (you add repos in exercises).
- **httpd** installed once from mirror, then repos removed.
- **SELinux:** enforcing.

## DNS / short names

`/etc/hosts` on servers includes:

```
192.168.55.149 repo.nine.example.com repo
192.168.55.150 server1.nine.example.com server1
192.168.55.151 server2.nine.example.com server2
```

So `http://repo/BaseOS` works without extra DNS.
