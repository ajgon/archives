from datetime import timedelta
from datetime import tzinfo
from datetime import datetime
import re


# Python way of singleton with shared states (but not exactly the same
# instances)
class Configuration(object):
    """Singleton containing all config parameters"""

    __shared_state = {}
    def __init__(self):
        self.__dict__ = self.__shared_state


class Timezone(tzinfo):
    """Basic tzinfo class to handle timezones"""

    def __init__(self, code='+0000'):
        if(re.match('(\+|-)[0-1][0-9][0-5][0-9]', code) is None):
            raise Exception('Invalid timezone code')
        self.code = 'GMT ' + code
        self.hours = int(code[0:3])
        self.minutes = int(code[3:5])

    def utcoffset(self, dt):
        return timedelta(hours=self.hours, minutes=self.minutes)

    def tzname(self, dt):
        return self.code

    def dst(self, dt):
        return timedelta(0)


class GitCache(object):
    """
    Internal caching system, created to avoid parse the same files multiple
    times.
    """
    def __init__(self, cache_time=900):
        self.cache_time = int(cache_time)
        self.cache = dict()

    def store(self, key, object, type='object'):
        """
        Store an object in a cache. Optional `type` parameter is used to avoid
        conflicts and categorize objects (i.e. one hash can be an object, or
        can be a delta from packfile which is part of this object).
        """
        self.cache[key + '_' + type] = dict(object=object, time=datetime.now())

    def read(self, key, type='object'):
        """
        Read object from cache. If object is obsolete or can't be found,
        None is returned.
        """
        if(not self.cache.has_key(key + '_' + type)):
            return None
        if((self.cache[key + '_' + type]['time'] + timedelta(0, self.cache_time) > datetime.now())):
            return self.cache[key + '_' + type]['object']
        else:
            del(self.cache[key + '_' + type])
            return None

    def flush(self):
        """
        Clean cache
        """
        self.cache = dict()
