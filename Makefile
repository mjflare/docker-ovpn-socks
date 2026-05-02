.PHONY: install deploy logs stop restart status clean help

help:
	@echo "OpenVPN Proxy Server - Make Commands"
	@echo ""
	@echo "  make install    - Run automated installer"
	@echo "  make deploy     - Deploy container (requires .env)"
	@echo "  make logs       - View container logs"
	@echo "  make stop       - Stop container"
	@echo "  make restart    - Restart container"
	@echo "  make status     - Check container status"
	@echo "  make shell      - Access container shell"
	@echo "  make clean      - Stop and remove container"


install:
	curl -fsSL https://raw.githubusercontent.com/mjflare/docker-ovpn-socks/main/install.sh | bash

deploy:
	docker-compose up -d

logs:
	docker-compose logs -f

stop:
	docker-compose down

restart:
	docker-compose restart

status:
	docker-compose ps

shell:
	docker-compose exec openvpn-proxy bash

clean:
	docker-compose down -v

.DEFAULT_GOAL := help
