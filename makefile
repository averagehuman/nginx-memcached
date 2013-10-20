
SHELL = /bin/bash

setup:
	@mkdir -p etc/buildout

uninstall:
	@if [ -e ./bin/uninstall ]; then \
	    echo "uninstalling"; \
		./bin/uninstall; \
		rm -f etc/buildout/.installed.cfg; \
	fi

install: setup
	@apt-get -y install zlib1g-dev libssl-dev libpcre3-dev libmhash-dev
	@apt-get -y install supervisor memcached
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

