# Linux Infrastructure Monitoring & Automation

Status: In Progress

## Overview

A hands-on Linux infrastructure project focused on server administration, infrastructure monitoring, Bash scripting and incident troubleshooting.

The lab uses an Ubuntu Server 24.04 LTS virtual machine hosted in VirtualBox.

## Technologies

- Ubuntu Server 24.04 LTS
- Oracle VirtualBox
- Bash scripting
- Nginx
- systemd services and timers
- SSH
- Git and GitHub

## Features Implemented

- Ubuntu Server installation and configuration
- SSH remote administration
- Nginx web server deployment
- Bash-based monitoring for Nginx, memory, disk and HTTP availability
- Monitoring severity levels using exit codes
- Automated health checks using systemd timers
- Timestamped monitoring logs
- Simulated service outages and recovery testing

## Current Development Status

The project is under active development. Planned improvements include log rotation, security hardening, additional monitoring capabilities and further infrastructure automation.

## Project Goal

Develop practical Linux system administration, monitoring and automation skills through a realistic server environment.

## Automated Email Alerts

The infrastructure monitoring system sends email notifications
using Gmail SMTP and msmtp.

### Alert Conditions
- CRITICAL: Nginx stops or the website becomes unavailable.
- WARNING: Memory or disk usage exceeds 80%.
- RECOVERY: The server returns to a healthy state.

### Notification Behaviour
- Alerts are sent only when the overall health status changes.
- Duplicate notifications are suppressed.
- Notifications include the hostname, status and timestamp.
- Email failures are logged without stopping the monitoring script.

### Security
- SMTP credentials are stored outside the Git repository.
- Credential files use restricted Linux permissions.
- AppArmor provides additional access controls.

### Testing
The notification system was tested by stopping Nginx,
verifying a critical alert, and restoring the service.
