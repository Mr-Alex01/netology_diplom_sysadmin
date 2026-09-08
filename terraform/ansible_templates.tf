# динамическое пересоздание hosts.ini
resource "local_file" "ansible_hosts" {
  filename = "${path.module}/../ansible/hosts.ini"
  content  = <<EOT
[bastion]
bastion-host ansible_host=${yandex_compute_instance.bastion.network_interface.0.nat_ip_address}

[web_servers]
web-server-1 ansible_host=${yandex_compute_instance.web_1.fqdn}
web-server-2 ansible_host=${yandex_compute_instance.web_2.fqdn}

[elastic]
elastic-server ansible_host=${yandex_compute_instance.elastic.fqdn}

[zabbix]
zabbix-server ansible_host=${yandex_compute_instance.zabbix.fqdn}

[kibana]
kibana-server ansible_host=${yandex_compute_instance.kibana.fqdn}

[all:vars]
ansible_ssh_common_args='-o StrictHostKeyChecking=no'
EOT
}

# динамическое пересоздание ansible.cfg
resource "local_file" "ansible_config" {
  filename = "${path.module}/../ansible/ansible.cfg"
  content  = <<EOT
[defaults]
host_key_checking = False
inventory = ./hosts.ini
remote_user = ubuntu

[ssh_connection]
ssh_args = -o ProxyCommand="ssh -W %h:%p -i \$HOME/.ssh/id_rsa -o StrictHostKeyChecking=no ubuntu@${yandex_compute_instance.bastion.network_interface.0.nat_ip_address}"
pipelining = True
EOT
}

# динамическое создание docker-compose для kibana
resource "local_file" "kibana_compose" {
  filename = "${path.module}/../ansible/roles/elastic_stack/templates/kibana-compose.yml.j2"
  content  = <<EOT

services:
  kibana:
    image: mirror.gcr.io/kibana:8.11.1
    container_name: kibana
    environment:
      - SERVER_NAME=kibana
      - SERVER_HOST=0.0.0.0
      - ELASTICSEARCH_HOSTS=http://${yandex_compute_instance.elastic.network_interface.0.ip_address}:9200
      - ELASTICSEARCH_SSL_VERIFICATIONMODE=none
      - XPACK_SECURITY_ENABLED=false
      - SERVER_PUBLICBASEURL=http://${yandex_compute_instance.kibana.network_interface.0.nat_ip_address}:5601
      - XPACK_SECURITY_ENCRYPTIONKEY=something_secret_32_chars_minimum_length
      - XPACK_ENCRYPTEDSAVEDOBJECTS_ENCRYPTIONKEY=something_secret_32_chars_minimum_length
      - XPACK_REPORTING_ENCRYPTIONKEY=something_secret_32_chars_minimum_length
    ports:
      - "5601:5601"
    restart: always
EOT
}

# динамическое создание docker-compose для elasticsearch
resource "local_file" "elastic_compose" {
  filename = "${path.module}/../ansible/roles/elastic_stack/templates/elastic-compose.yml.j2"
  content  = <<EOT

services:
  elasticsearch:
    image: mirror.gcr.io/elasticsearch:8.11.1
    container_name: elasticsearch
    environment:
      - discovery.type=single-node
      - xpack.security.enabled=false
      - network.host=0.0.0.0
      - "ES_JAVA_OPTS=-Xms512m -Xmx512m"
    volumes:
      - elastic_data:/usr/share/elasticsearch/data
    ports:
      - "9200:9200"
    restart: always

volumes:
  elastic_data:
EOT
}