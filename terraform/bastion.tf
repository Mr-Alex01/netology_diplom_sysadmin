data "yandex_compute_image" "ubuntu_2404" {
  family = "ubuntu-2404-lts"
}

resource "yandex_compute_instance" "bastion" {
  name        = "bastion-host"
  hostname    = "bastion"
  zone        = "ru-central1-a"
  platform_id = "standard-v3"

# с минимальным конфигом
  resources {
    cores         = 2
    memory        = 2
    core_fraction = 20
  }
# прерываемая
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
    nat       = true # включение публичный ip
    security_group_ids = [yandex_vpc_security_group.bastion_sg.id]
  }

  metadata = {
      enable-oslogin = "true"
# добавляю ключ из переменной чтоб его не светить
    ssh-keys       = "ubuntu:${var.ssh_public_key}"
  }
}
