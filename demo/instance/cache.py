
import hashlib
import logging

from django.conf import settings
from django.core.cache import get_cache
from django.utils.decorators import decorator_from_middleware_with_args

COOKIE = 'pubid'
CACHE = 'page'

md5 = hashlib.md5
log = logging.getLogger(__name__)
cache = get_cache(CACHE)

def get_cache_key(host, path, version):
    """Use the request path and page version to get cache key."""
    return md5(
        u'%s%s&%s=%s' % (host, path, COOKIE, version)
    ).hexdigest()


class UpdateCacheMiddleware(object):

    def __init__(self, seconds=600, version_fn=None):
        """Initialize middleware. Args:
            * seconds - seconds after which the cached response expires
        """
        self.seconds = seconds
        self.version_fn = version_fn

    def process_response(self, request, response):
        """Sets the cache, if needed."""
        if request.method != 'GET' or response.status_code != 200:
            return response
        # Logged in users don't cause caching
        if request.user.is_authenticated():
            return response
        try:
            version = response.version
        except AttributeError:
            version = getattr(request.site.state, self.attr)
        key = get_cache_key(
            request.get_host(),
            request.get_full_path(),
            version,
        )
        log.info("CACHE RESPONSE - %s" % key)
        cache.set(
            key,
            response.content,
            self.seconds,
        )
        # Store the version
        response.set_cookie(COOKIE, version)
        return response

cache_page = decorator_from_middleware_with_args(UpdateCacheMiddleware)

