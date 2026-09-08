# private

# web 1 (zone a - private)
resource "yandex_compute_instance" "web_1" {
  name        = "web-server-1"
  hostname    = "web-1"
  zone        = "ru-central1-a"
  platform_id = "standard-v3"

  resources {
    cores         = 2
    memory        = 2
    core_fraction = 20
  }

  scheduling_policy {
    preemptible = true
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu_2404.id
      type     = "network-hdd"
      size     = 10
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.private_a.id
    nat       = false
    security_group_ids = [yandex_vpc_security_group.internal_sg.id]
  }

  metadata = {
    enable-oslogin = "true"
    ssh-keys       = "ubuntu:${var.ssh_public_key}"
  }
}

# web 2 (zone b - private, reserve)
resource "yandex_compute_instance" "web_2" {
  name        = "web-server-2"
  hostname    = "web-2"
  zone        = "ru-central1-b"
  platform_id = "standard-v3"

  resources {
    cores         = 2
    memory        = 2
    core_fraction = 20
  }

  scheduling_policy {
    preemptible = true
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu_2404.id
      type     = "network-hdd"
      size     = 10
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.private_b.id
    nat       = false
    security_group_ids = [yandex_vpc_security_group.internal_sg.id]
  }

  metadata = {
    enable-oslogin = "true"
    ssh-keys       = "ubuntu:${var.ssh_public_key}"
  }
}

# elastic (zone a - private)
resource "yandex_compute_instance" "elastic" {
  name        = "elastic-server"
  hostname    = "elastic"
  zone        = "ru-central1-a"
  platform_id = "standard-v3"

  resources {
    cores         = 2
    memory        = 2
    core_fraction = 20
  }

  scheduling_policy {
    preemptible = true
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu_2404.id
      type     = "network-hdd"
      size     = 10
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.private_a.id
    nat       = false
    security_group_ids = [yandex_vpc_security_group.internal_sg.id]
  }

  metadata = {
    enable-oslogin = "true"
    ssh-keys       = "ubuntu:${var.ssh_public_key}"
  }
}

# public

# zabbix (zone a - public)
resource "yandex_compute_instance" "zabbix" {
  name        = "zabbix-server"
  hostname    = "zabbix"
  zone        = "ru-central1-a"
  platform_id = "standard-v3"

  resources {
    cores         = 2
    memory        = 2
    core_fraction = 20
  }

  scheduling_policy {
    preemptible = true
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu_2404.id
      type     = "network-hdd"
      size     = 10
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.public_a.id
    nat       = true # включаю публичный IP для веб-интерфейса
    security_group_ids = [yandex_vpc_security_group.monitoring_sg.id]
  }

  metadata = {
    enable-oslogin = "true"
    ssh-keys       = "ubuntu:${var.ssh_public_key}"
  }
}

# kibana (zone a - public)
resource "yandex_compute_instance" "kibana" {
  name        = "kibana-server"
  hostname    = "kibana"
  zone        = "ru-central1-a"
  platform_id = "standard-v3"

  resources {
    cores         = 2
    memory        = 2
    core_fraction = 20
  }

  scheduling_policy {
    preemptible = true
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu_2404.id
      type     = "network-hdd"
      size     = 10
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.public_a.id
    nat       = true # включаю публичный IP для веб-интерфейса
    security_group_ids = [yandex_vpc_security_group.monitoring_sg.id]
  }

  metadata = {
    enable-oslogin = "true"
    ssh-keys       = "ubuntu:${var.ssh_public_key}"
  }
}
