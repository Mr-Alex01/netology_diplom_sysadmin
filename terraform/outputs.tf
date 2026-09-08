output "network_id" {
  value = yandex_vpc_network.main.id
}

output "bastion_public_ip" {
  value = yandex_compute_instance.bastion.network_interface.0.nat_ip_address
}

# private IP
output "web_1_private_ip" {
  value = yandex_compute_instance.web_1.network_interface.0.ip_address
}

output "web_2_private_ip" {
  value = yandex_compute_instance.web_2.network_interface.0.ip_address
}

output "elastic_private_ip" {
  value = yandex_compute_instance.elastic.network_interface.0.ip_address
}

# public IP
output "zabbix_public_ip" {
  value = yandex_compute_instance.zabbix.network_interface.0.nat_ip_address
}

output "kibana_public_ip" {
  value = yandex_compute_instance.kibana.network_interface.0.nat_ip_address
}

# узнать внешний IP-адрес, по которому сайт будет открываться в браузере
output "alb_public_ip" {
  value       = yandex_alb_load_balancer.web_alb.listener.0.endpoint.0.address.0.external_ipv4_address.0.address
}
