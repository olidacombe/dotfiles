# Old Macbook

## irq-9/acpi Hammering CPU

```bash
yay cronie
sudo systemctl enable cronie

cat << EOF | sudo crontab -u root
@reboot echo "mask" > /sys/firmware/acpi/interrupts/gpe06
@reboot echo "disable" > /sys/firmware/acpi/interrupts/gpe06
EOF

sudo systemctl start cronie
```
