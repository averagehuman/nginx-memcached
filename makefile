
SHELL = /bin/bash

setup:
	@mkdir -p etc/buildout

defaults:
	@if [ ! -e base.cfg ]; then \
		echo "" > base.cfg ; \
		echo "[nginx]" >> base.cfg ; \
		echo "version = 1.4.3" >> base.cfg ; \
		echo "prefix = /opt/nginx/\$${nginx:version}" >> base.cfg ; \
		echo "logdir = /opt/nginx/\$${nginx:version}/logs" >> base.cfg ; \
		echo "tmpdir = /opt/nginx/\$${nginx:version}/run" >> base.cfg ; \
		echo "worker_processes = auto" >> base.cfg ; \
		echo "worker_connections = 1024" >> base.cfg ; \
		echo "server_name = _" >> base.cfg ; \
		echo "listen = 80" >> base.cfg ; \
		echo "asset_root = /var/www/assets" >> base.cfg ; \
		echo "media_root = /var/www/media" >> base.cfg ; \
		echo "cache_prefix = a" >> base.cfg ; \
		echo "cache_version = 1" >> base.cfg ; \
		echo "user = www" >> base.cfg ; \
		echo "group = www" >> base.cfg ; \
		echo "admin = admin" >> base.cfg ; \
		echo "" >> base.cfg ; \
		echo "[proxy]" >> base.cfg ; \
		echo "type = http" >> base.cfg ; \
		echo "application = django" >> base.cfg ; \
		echo "servers =" >> base.cfg ; \
		echo "    unix:/tmp/\$${proxy:application}/local-proxy" >> base.cfg ; \
		echo "" >> base.cfg ; \
		echo "[memcached]" >> base.cfg ; \
		echo "socket = /tmp/local-memcache" >> base.cfg ; \
		echo "mem = 64" >> base.cfg ; \
		echo "" >> base.cfg ; \
	fi

uninstall:
	@if [ -e ./bin/uninstall ]; then \
	    echo "uninstalling"; \
		./bin/uninstall; \
		rm -f etc/buildout/.installed.cfg; \
	fi

install: setup defaults
	@apt-get -y install supervisor
	@if [ ! -e etc/buildout/.installed.cfg ]; then \
		d=$$(dirname $$(pwd)); \
		py="python"; \
		until [ "$$d" = "/" ]; do \
			if [ -e "$$d/bin/python" ]; then \
				py="$$d/bin/python"; \
				break; \
			fi; \
		d=$$(dirname $$d); \
		done; \
		echo "Bootstrapping with $$py"; \
		$$py bootstrap.py; \
	fi;
	@./bin/buildout
	@./bin/install

reinstall: uninstall install

