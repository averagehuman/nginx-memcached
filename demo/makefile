

setup:
	@mkdir -p etc/buildout


configure: setup
	@if [ ! -e "etc/buildout/.installed.cfg" ]; then \
		d=$$(dirname $$(pwd)); \
		py="python"; \
		until [ "$$d" = "/" ]; do \
			if [ -e "$$d/bin/python" ]; then \
				py="$$d/bin/python"; \
				break; \
			fi; \
		d=$$(dirname $$d); \
		done; \
		echo "Bootstrapping with $$($$py -c 'import sys;print(sys.executable)')"; \
		$$py bootstrap.py; \
	fi;
	@./bin/buildout

collectstatic:
	@./bin/django collectstatic --traceback --noinput -i '*.js' -i '*.css' -i '*.rb' -i '*.scss' -i '.sass-cache' -i '*.txt'

compress:
	@./bin/django compress --traceback

assets: collectstatic compress

fixtures:
	@for f in $$(find instance -type f -path "*/fixtures/*" -regex ".*\.xml$$\|.*\.json$$"); do ./bin/django loaddata $$f; done

site: configure assets fixtures
	@./bin/django clear_cache

serve:
	@./bin/django runserver


