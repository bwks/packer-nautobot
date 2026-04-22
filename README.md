# packer-nautobot

Packer build that produces a qcow2 disk image with [Nautobot](https://docs.nautobot.com/) pre-installed on Ubuntu 24.04 (Noble). The image is ready to boot under QEMU/KVM with no further provisioning required.

## What's in the image

| Component | Details |
|-----------|---------|
| OS | Ubuntu 24.04 LTS (Noble), fully upgraded |
| Nautobot | Pinned release (default `3.0.8`, overridable), installed in a Python venv at `/opt/nautobot` |
| Plugins | `nautobot_bgp_models`, `nautobot_plugin_nornir`, `nautobot_circuit_maintenance` |
| Database | PostgreSQL (local, `nautobot` DB + user) |
| Cache / broker | Redis |
| Web server | Nginx → uWSGI socket |
| Services | `nautobot`, `nautobot-worker`, `nautobot-scheduler` (systemd, enabled at boot) |

## Requirements

- [Packer](https://developer.hashicorp.com/packer/install) ≥ 1.9
- QEMU with KVM (`qemu-system-x86_64`, `qemu-kvm`)
- ~5 GB free disk space for the build VM and output image

On macOS, replace `accelerator` with `hvf` (see [Variables](#variables) below).

## Usage

```sh
packer init .
packer validate .
packer build .
```

The output image is written to `output/nautobot.qcow2` by default.

## Variables

Override any variable with `-var 'name=value'` or a `.pkrvars.hcl` file.

| Variable | Default | Description |
|----------|---------|-------------|
| `ubuntu_iso_url` | Ubuntu 24.04 cloud image | Source image URL |
| `ubuntu_iso_checksum` | `file:…/SHA256SUMS` | Checksum (verified automatically) |
| `output_directory` | `output` | Directory for the built image |
| `vm_name` | `nautobot` | Output filename (without `.qcow2`) |
| `nautobot_version` | `3.0.8` | Nautobot release to install. Empty string means latest. |
| `disk_size` | `20480` (20 GB) | Disk size in MB, sparse qcow2 |
| `memory` | `4096` | Build VM RAM in MB |
| `cpus` | `2` | Build VM CPU count |
| `accelerator` | `kvm` | QEMU accelerator: `kvm`, `hvf`, or `none` |

Example — build with more RAM and a custom output path:

```sh
packer build -var 'memory=8192' -var 'output_directory=/var/lib/libvirt/images' .
```

Example — build a different Nautobot release:

```sh
packer build -var 'nautobot_version=2.4.0' .
```

## First-boot checklist

1. **Change the superuser password.** A default admin account is created during the build:
   - Username: `admin`
   - Password: `admin`

   Log in at `http://<ip>/` and change it immediately, or reset it via the CLI:
   ```sh
   sudo -u nautobot /opt/nautobot/bin/nautobot-server changepassword admin
   ```

2. **Restrict `ALLOWED_HOSTS`.** The default config accepts any hostname (`*`). Edit `/opt/nautobot/nautobot_config.py` or set the `NAUTOBOT_ALLOWED_HOSTS` environment variable.

3. **Rotate the secret key.** A random key is baked in at build time. For production, override it:
   ```sh
   export NAUTOBOT_SECRET_KEY="your-strong-secret"
   ```

4. **Check services are running:**
   ```sh
   systemctl status nautobot nautobot-worker nautobot-scheduler
   ```

## Configuration

Key environment variables read by `nautobot_config.py`:

| Variable | Default | Purpose |
|----------|---------|---------|
| `NAUTOBOT_SECRET_KEY` | baked-in random value | Django secret key |
| `NAUTOBOT_ALLOWED_HOSTS` | `*` | Comma-separated hostnames |
| `NAUTOBOT_DB_HOST` | `localhost` | PostgreSQL host |
| `NAUTOBOT_DB_PASSWORD` | `nautobot` | PostgreSQL password |
| `NAUTOBOT_REDIS_URL` | `redis://localhost:6379/1` | Redis cache URL |
| `NAUTOBOT_CELERY_BROKER_URL` | `redis://localhost:6379/0` | Celery broker URL |
| `NAUTOBOT_DEBUG` | `false` | Enable Django debug mode |

## License

See [LICENSE](LICENSE).
