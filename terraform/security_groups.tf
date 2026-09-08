# for bastion
resource "yandex_vpc_security_group" "bastion_sg" {
  name       = "bastion-security-group"
  network_id = yandex_vpc_network.main.id
  
  ingress {
    protocol       = "TCP"
    description    = "allow ssh from anywhere"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 22
  }

    ingress {
    protocol       = "TCP"
    description    = "Allow Zabbix Agent"
    v4_cidr_blocks = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
    from_port      = 10050
    to_port        = 10050
  }
  
  egress {
    protocol       = "ANY"
    description    = "allow all outbound traffic"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 0
    to_port        = 65535
  }
}

# for ALB
resource "yandex_vpc_security_group" "alb_sg" {
  name       = "alb-security-group"
  network_id = yandex_vpc_network.main.id
  
  ingress {
    protocol       = "TCP"
    description    = "allow http from anywhere"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 80
  }
  
  ingress {
    protocol       = "TCP"
    description    = "allow health checks from alb"
    predefined_target = "loadbalancer_healthchecks"
    port           = 80
  }
  
  egress {
    protocol       = "TCP"
    description    = "allow outbound to web servers"
    v4_cidr_blocks = ["10.0.2.0/24", "10.0.3.0/24"]
    port           = 80
  }
}

# for web + elastic
resource "yandex_vpc_security_group" "internal_sg" {
  name       = "internal-security-group"
  network_id = yandex_vpc_network.main.id
  
  ingress {
    protocol       = "TCP"
    description    = "allow ssh only from bastion network"
    v4_cidr_blocks = ["10.0.1.0/24"]
    port           = 22
  }
  
  ingress {
    protocol       = "TCP"
    description    = "allow http traffic from alb"
    v4_cidr_blocks = ["10.0.1.0/24", "10.0.3.0/24"]
    port           = 80
  }
  
  ingress {
    protocol       = "TCP"
    description    = "allow elasticsearch internal traffic"
    v4_cidr_blocks = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
    port           = 9200
  }
  
  ingress {
    protocol       = "TCP"
    description    = "allow zabbix agent traffic"
    v4_cidr_blocks = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
    port           = 10050
  }
  
  egress {
    protocol       = "ANY"
    description    = "allow all outbound traffic via nat"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 0
    to_port        = 65535
  }
}

# for zabbix + kibana
resource "yandex_vpc_security_group" "monitoring_sg" {
  name       = "monitoring-security-group"
  network_id = yandex_vpc_network.main.id

  ingress {
    protocol       = "TCP"
    description    = "Allow SSH"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 22
    to_port        = 22
  }

  ingress {
    protocol       = "TCP"
    description    = "Allow Zabbix Web UI"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 80
    to_port        = 80
  }

    ingress {
    protocol       = "TCP"
    description    = "Allow Zabbix Trapper"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 10051
    to_port        = 10051
  }

  ingress {
    protocol       = "TCP"
    description    = "Allow Kibana Web UI"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 5601
    to_port        = 5601
  }

  ingress {
    protocol          = "TCP"
    description       = "Allow traffic from Yandex ALB"
    predefined_target = "loadbalancer_healthchecks"
    from_port         = 0
    to_port           = 65535
  }

  ingress {
    protocol       = "ANY"
    description    = "Allow all internal VPC traffic"
    v4_cidr_blocks = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
    from_port      = 0
    to_port        = 65535
  }

   egress {
    protocol       = "ANY"
    description    = "Allow all outbound traffic"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 0
    to_port        = 65535
  }
}

