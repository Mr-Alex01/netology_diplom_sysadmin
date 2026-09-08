terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = ">= 0.221.0"
    }
  }
  required_version = ">= 1.5.0"
}

provider "yandex" {
  cloud_id  = "b1gc666op2jmi5rgh3ii"
  folder_id = "b1g5l5sj31nvr8gv75gl"  
  zone      = "ru-central1-a"
}