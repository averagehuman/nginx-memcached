
nginx-memcached - compile and install nginx with memcached support
==================================================================

For a given request uri representing some versioned page, arrange for your
backend dynamic web app to set a page cookie whose value is the version string (a
timestamp or unique id), then create an md5 hash of the uri together with the
version and save the page's HTML content to a local memcache server using the
hash as key. Then configure nginx to create the same md5 uri/version hash key
for each request and query the memcached server for this key - if found, serve
the page and so avoid hitting the backend, if not, pass on the request to the
dynamic proxy.

This is intended for per-page caching for non-logged in users, but might also be
adaptable to fragment caching and per-user caching.

Why not Varnish?
----------------

Or use Varnish. Whatever makes you happy.

Credit
------

This has all been adapted from `django-nginx-memcache`_ by `torchbox`_, which was
itself adapted from an original project by Paul Craciunoiu described `here`_.

Usage
-----

Intended for use on Ubuntu 12.04.

In the source directory run::

    $ sudo make install

This installs by default to ``/opt/nginx/<nginx-version>``, and adds
``supervisord`` and ``logrotate`` configurations to the appropriate places.
It also adds a secondary ``memcached`` configuration (in addition to the
primary ``memcached`` server running on port 11211 say). This secondary server
runs on a local unix domain socket, by default ``/tmp/local-memcahe``, and the
backend app should be configured to use this socket. For example, for Django::

    CACHES = {
        'default': {
            'LOCATION': ['127.0.0.1:11211',],
            'KEY_PREFIX': '',
            'VERSION': '1',
            'BACKEND': 'johnny.backends.memcached.MemcachedCache',
            'TIMEOUT':0,
            'JOHNNY_CACHE': True,
        },
        'page': {
            'LOCATION': 'unix:/tmp/local-memcache',
            'BACKEND': 'django.core.cache.backends.memcached.MemcachedCache',
            'KEY_PREFIX': '',
            'VERSION': '1',
            'TIMEOUT': 3600,
        },
    }

To start nginx, run::

    $ sudo supervisorctl reread
    $ sudo supervisorctl update

The secondary memcached server's configuration is copied to
``/etc/memcached_local_cache.conf``, and this will run on system startup or by
running::

    $ sudo service memcached restart

Now you just have to ensure your backend, gunicorn say, is running and
that the proxy settings in the nginx config (``/opt/nginx/<nginx-version>/conf/nginx.conf``)
are correct for that backend.

Defaults
--------

To change nginx and proxy options, update the ``base.cfg`` in the source directory
before running ``make install``. The default ``base.cfg`` is as folows::

    [nginx]
    version = 1.4.3
    prefix = /opt/nginx/${nginx:version}
    logdir = /opt/nginx/${nginx:version}/logs
    tmpdir = /opt/nginx/${nginx:version}/run
    worker_processes = auto
    worker_connections = 1024
    server_name = _
    listen = 80
    asset_root = /var/www/assets
    media_root = /var/www/media
    cache_prefix = a
    cache_version = 1
    user = www
    group = www
    admin = admin

    [proxy]
    type = http
    application = django
    servers =
        unix:/tmp/${proxy:application}/local-proxy

    [memcached]
    socket = /tmp/local-memcache
    mem = 64


.. _django-nginx-memcache: https://github.com/torchbox/django-nginx-memcache
.. _torchbox: http://www.torchbox.com/
.. _here: http://embrangler.com/2012/01/caching-django-views-with-nginx-and-memcache/

