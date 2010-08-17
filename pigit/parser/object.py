import re

from pigit.parser import Parser
from pigit.gitobjects import Raw

class Object(Parser):
    """Parser class for .git/objects files"""

    def __init__(self):
        self.contents = None
        super(Object, self).__init__()

    def read(self, hash):
        """Reads an object file and returns Raw gitobject object"""
        contents = self.uncompress(self.hash_to_path(hash))
        type = re.match('(?P<type>[a-z]+) ', contents).group('type')
        return Raw(hash, type, re.sub('^[^\000]+\000', '', contents))
