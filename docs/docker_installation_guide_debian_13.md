# Complete Guide: Installing Docker Engine on Debian 13 (Trixie) & Configuring Custom Data Root

This guide provides step-by-step instructions for installing the official Docker Engine on **Debian 13 (Trixie)** and configuring Docker to store all images, containers, and volumes in a custom directory (such as `/data/docker_images`).

---

## 1. Clean Up Broken Repositories (If Applicable)

If an incorrect repository (such as an Ubuntu release line) was previously added, remove it to prevent `404 Not Found` errors during APT updates:

```bash
sudo rm -f /etc/apt/sources.list.d/docker.list
```

---

## 2. Install Docker Engine

Follow these steps to set up Docker's official **Debian** repository and install the packages.

### Step 2.1: Add Docker's Official GPG Key

```bash
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg

sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
```

### Step 2.2: Add the Debian Repository

```bash
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

### Step 2.3: Install Docker Packages

```bash
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

---

## 3. Configure Custom Docker Root Directory

By default, Docker stores data in `/var/lib/docker`. The steps below route storage to a custom directory, such as `/data/docker_images`.

### Step 3.1: Stop Docker Daemon

```bash
sudo systemctl stop docker
```

* **Verification:** Run `sudo systemctl status docker` to ensure the status reads `inactive (dead)`.

### Step 3.2: Create Directory and Update Configuration

Create the target directory and write the configuration to `/etc/docker/daemon.json`:

```bash
sudo mkdir -p /data/docker_images

sudo tee /etc/docker/daemon.json <<EOF
{
  "data-root": "/data/docker_images"
}
EOF
```

*(Optional)* If images were already pulled into `/var/lib/docker` and need to be moved to the new path:
```bash
sudo rsync -aP /var/lib/docker/ /data/docker_images/
```

### Step 3.3: Restart Docker & Verify Storage Path

Reload systemd configurations and restart Docker:

```bash
sudo systemctl daemon-reload
sudo systemctl start docker
```

* **Verification:** Check the active Docker root directory:
  ```bash
  docker info | grep "Docker Root Dir"
  ```
  **Expected Output:** `Docker Root Dir: /data/docker_images`

---

## 4. Post-Installation Configuration

### Enable Docker Service on Boot

Ensure the Docker service starts automatically upon server reboots:

```bash
sudo systemctl enable docker
```

### Manage Docker as a Non-Root User

To allow your current user to execute `docker` commands without `sudo`:

```bash
sudo usermod -aG docker $USER
newgrp docker
```

---

## 5. Summary Cheat Sheet

| Task | Command |
| :--- | :--- |
| **Verify Root Directory** | `docker info \| grep "Docker Root Dir"` |
| **Check Boot Status** | `sudo systemctl is-enabled docker` |
| **Run Container with Auto-Restart** | `docker run -d --restart unless-stopped <image>` |
| **Set Auto-Restart on Existing Container** | `docker update --restart unless-stopped <container_name_or_id>` |