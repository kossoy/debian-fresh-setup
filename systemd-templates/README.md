# Systemd User Service Templates

This directory contains systemd service templates for running user-level services on Debian.

## Service Types

### 1. Web Application Service (`example-webapp.service`)
Template for Node.js web applications.

### 2. Python Application Service (`example-python-app.service`)
Template for Python applications.

### 3. Timer Service (`example-timer.timer` + `example-script.service`)
Template for scheduled tasks (like cron).

## How to Use

### 1. Copy Template to User Systemd Directory

```bash
# Create user systemd directory
mkdir -p ~/.config/systemd/user

# Copy and rename template
cp systemd-templates/example-webapp.service ~/.config/systemd/user/my-app.service
```

### 2. Edit the Service File

```bash
# Edit the service file
nano ~/.config/systemd/user/my-app.service

# Update these fields:
# - Description
# - WorkingDirectory
# - Environment variables
# - ExecStart command
# - User (use your username or %u for current user)
```

### 3. Reload Systemd and Enable Service

```bash
# Reload systemd user daemon
systemctl --user daemon-reload

# Enable service to start on boot
systemctl --user enable my-app.service

# Start service now
systemctl --user start my-app.service

# Check status
systemctl --user status my-app.service
```

### 4. View Logs

```bash
# View service logs
journalctl --user -u my-app.service

# Follow logs in real-time
journalctl --user -u my-app.service -f

# View last 50 lines
journalctl --user -u my-app.service -n 50
```

## Common Commands

```bash
# Start service
systemctl --user start my-app.service

# Stop service
systemctl --user stop my-app.service

# Restart service
systemctl --user restart my-app.service

# Enable on boot
systemctl --user enable my-app.service

# Disable on boot
systemctl --user disable my-app.service

# Check status
systemctl --user status my-app.service

# List all user services
systemctl --user list-units --type=service

# Reload service file after editing
systemctl --user daemon-reload
```

## Timer Services

For scheduled tasks (alternative to cron):

### 1. Create Service and Timer Files

```bash
# Copy both files
cp systemd-templates/example-script.service ~/.config/systemd/user/backup.service
cp systemd-templates/example-timer.timer ~/.config/systemd/user/backup.timer

# Edit both files as needed
```

### 2. Enable and Start Timer

```bash
# Enable timer
systemctl --user enable backup.timer

# Start timer
systemctl --user start backup.timer

# Check timer status
systemctl --user list-timers

# Check when timer will run next
systemctl --user status backup.timer
```

## Service File Variables

- `%u` - Current username
- `%h` - User home directory
- `%H` - Host name

## Example: Node.js Web App

```bash
# 1. Create service file
cat > ~/.config/systemd/user/my-webapp.service << 'SERVICEEOF'
[Unit]
Description=My Web Application
After=network.target

[Service]
Type=simple
WorkingDirectory=/home/myuser/work/projects/personal/my-webapp
Environment="NODE_ENV=production"
Environment="PORT=3000"
ExecStart=/usr/bin/node server.js
Restart=on-failure
RestartSec=10

[Install]
WantedBy=default.target
SERVICEEOF

# 2. Reload and start
systemctl --user daemon-reload
systemctl --user enable my-webapp.service
systemctl --user start my-webapp.service

# 3. Check status
systemctl --user status my-webapp.service
```

## Enable Lingering

To keep user services running even when not logged in:

```bash
# Enable lingering for your user
loginctl enable-linger $USER

# Check lingering status
loginctl show-user $USER | grep Linger
```

## Troubleshooting

### Service Won't Start

```bash
# Check service status and logs
systemctl --user status my-app.service
journalctl --user -u my-app.service -n 100

# Verify service file syntax
systemd-analyze verify ~/.config/systemd/user/my-app.service
```

### Permission Errors

```bash
# Ensure service file is readable
chmod 644 ~/.config/systemd/user/my-app.service

# Ensure executable has correct permissions
chmod +x /path/to/executable
```

### Environment Variables Not Working

```bash
# Use EnvironmentFile for multiple variables
# In service file:
EnvironmentFile=%h/.config/my-app/env

# Create env file:
echo "NODE_ENV=production" > ~/.config/my-app/env
echo "PORT=3000" >> ~/.config/my-app/env
```

## Best Practices

1. **Use user services** for user-level applications (not system services)
2. **Enable lingering** if services should run when not logged in
3. **Use timers** instead of cron for scheduled tasks
4. **Set Restart=on-failure** for services that should auto-restart
5. **Use EnvironmentFile** for configuration
6. **Always reload** systemd after editing service files
7. **Check logs** with journalctl for debugging

---

**Last Updated**: October 26, 2025
