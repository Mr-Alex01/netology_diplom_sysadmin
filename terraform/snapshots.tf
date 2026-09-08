resource "yandex_compute_snapshot_schedule" "daily_backup" {
  name        = "daily-disk-snapshot-schedule"
  description = "Daily disk backup of all VMs with a service life of 7 days"

  # cron: каждый день в 2 ночи по UTC
  schedule_policy {
    expression = "0 2 * * *"
  }

  # snapshot lifetime limit: exactly 7 days (168h)
  retention_period = "168h"

  # linking disks of all created instances
  disk_ids = [
    yandex_compute_instance.bastion.boot_disk.0.disk_id,
    yandex_compute_instance.web_1.boot_disk.0.disk_id,
    yandex_compute_instance.web_2.boot_disk.0.disk_id,
    yandex_compute_instance.elastic.boot_disk.0.disk_id,
    yandex_compute_instance.kibana.boot_disk.0.disk_id,
    yandex_compute_instance.zabbix.boot_disk.0.disk_id
  ]

  # snapshot naming settings for debugging
  snapshot_spec {
    description = "automatic daily disk snapshot"
    labels = {
      environment = "production"
      managed-by  = "terraform"
    }
  }
}
