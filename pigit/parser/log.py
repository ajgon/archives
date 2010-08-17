#TODO: completely rewrite or remove
import os.path
import re

from pigit.parser import Parser

class Log(Parser):
    """Parser class for .git/logs files"""

    def __init__(self):
        super(Log, self)
        self.log_path = os.path.join(self.git_path, 'logs/HEAD')
        log_content = open(self.log_path, 'r')
        self.entries = self.__get_entries(log_content)

    def __get_entries(self, log_content):
        """Returns log file contents as dictionary"""
        entries = []
        lines = log_content.readlines()
        for line in lines:
            matches = re.match('^([0-9a-f]{40}) ([0-9a-f]{40}) ' +
                               '([^<]*)(<([^>]+)>)? ([0-9]+) ' +
                               '([\+0-9]+)\x09([^:]+):(.*)$', line)
            entry = dict(fromSha = matches.group(1),
                         toSha = matches.group(2),
                         name = matches.group(3).strip(),
                         email = matches.group(5),
                         timestamp = int(matches.group(6)),
                         timezone = matches.group(7),
                         type = matches.group(8),
                         message = matches.group(9))
            entries.append(entry)
        return entries