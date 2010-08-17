import os.path
import re

from pigit.parser import Parser


class Ref(Parser):
    """Parser class for .git/refs/ files"""

    def head_hash(self, ref=None):
        """Returns hash of head commit in specified branch"""
        if(ref is None):
            return open(os.path.join(self.git_path, self.head_reference()),
                        'r').read().strip("\n")

        if(re.match('[0-9a-f]{40}', ref)):
            return ref

        path = os.path.join(self.git_path, 'refs', 'heads', ref)
        if(not os.path.exists(path)):
            path = os.path.join(self.git_path, 'refs', 'tags', ref)
        if(not os.path.exists(path)):
            raise Exception('Specified reference does not exists')

        return open(path, 'r').read().strip("\n")
