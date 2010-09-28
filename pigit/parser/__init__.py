import os.path
import zlib
import re
from datetime import datetime
from pigit.common import Timezone
from math import ceil
import binascii
import ConfigParser
from io import StringIO


from pigit.common import Configuration
from pigit.common import GitCache
from pigit.gitobjects import *


class Parser(object):
    """
    Main class, each .git parser extends it
    Class itself is used to automagically find any data associated with
    given hash
    """

    def __init__(self):
        conf = Configuration()
        self.git_path = conf.git_path

    def hash_to_path(self, hash):
        """Returns full path to object file identified by given hash"""
        return os.path.join(self.git_path, 'objects', hash[0:2], hash[2:40])

    def uncompress(self, filepath):
        """Uncompresses file using zlib"""
        return self.uncompress_string(open(filepath, 'r').read())

    def uncompress_string(self, string):
        """Uncompresses string using zlib"""
        return zlib.decompress(string)

    def read(self, hash):
        """Returns uncompressed raw object by given hash"""
        # We need to determine is file exists in git file system or
        # is it stored in pack file
        packed = False if(os.path.isfile(self.hash_to_path(hash))) else True
        if(packed):
            return self.read_pack(hash)
        else:
            return self.read_object(hash)

    def read_pack(self, hash):
        """Returns uncompressed raw object from packfile by given hash"""
        conf = Configuration()
        for pack in conf.packs:
            result = pack.read(hash)
            if result:
                return result

    def read_object(self, hash):
        """Returns uncompressed raw object from objectfile by given hash"""
        from pigit.parser.object import Object
        return Object().read(hash)


    def head_reference(self):
        """
        Returns file path which is reference in .git/HEAD.
        This file is a reference file of active branch which contains
        hash of last commit
        """
        return open(os.path.join(self.git_path, 'HEAD'), 'r').read()[5:-1]

    def parse(self, hash, type=None):
        """
        Used to fetch any data associated with given hash in git file system.
        Method itself determines is it in pack file or in object file, and if
        finds anything, returns corresponding object. 
        """

        raw = self.read(hash)
        
        if not raw:
            raise Exception('Invalid hash')
        
        if(type is not None and type != raw.type):
            raise Exception('Invalid type - "' + type +
                            '" was expected, but "' + raw.type + '" found.')

        if(raw.type == 'commit'):
            gitobject = self.parse_commit(raw)
        elif(raw.type == 'tag'):
            gitobject = self.parse_tag(raw)
        elif(raw.type == 'tree'):
            gitobject = self.parse_tree(raw)
        elif(raw.type == 'blob'):
            gitobject = self.parse_blob(raw)
        else:
            raise Exception('Unknown object found! This should not happen')

        return gitobject

    def parse_commit(self, raw):
        """
        Explicitly assumes that commit raw object is provided, then parses it
        and returns corresponding Commit object.
        If wrong raw is given, exception is thrown
        """

        if(raw.type != 'commit'):
            raise Exception('Provided raw is not a commit raw')

        matches = re.match('(tree (?P<tree>[0-9a-f]{40})\n)?' +
                           '(?P<parents>(parent ([0-9a-f]{40})\n)*)' +
                           'author (?P<author_name>[^<]*)' +
                               '(<(?P<author_email>[^>]+)>)? ' +
                               '(?P<authored_date_timestamp>[0-9]+) ' +
                               '(?P<authored_date_tzone>(\+|-)[0-9]{4})?\n' +
                           'committer (?P<committer_name>[^<]*)' +
                               '(<(?P<committer_email>[^>]+)>)? ' +
                               '(?P<committed_date_timestamp>[0-9]+) ' +
                               '(?P<committed_date_tzone>(\+|-)[0-9]{4})?\n' +
                           '\n(?P<message>.*)', raw.contents, re.DOTALL)

        if matches is None:
            raise Exception('Cannot parse raw as a commit raw')

        parents = []
        if(matches.group('parents') != ''):
            parents = matches.group('parents').replace('parent ', '') \
                             .strip("\n").split("\n")

        return Commit(raw.hash,
                      matches.group('tree'),
                      Author(matches.group('author_name'),
                             matches.group('author_email')),
                      datetime.fromtimestamp(int(matches.group('authored_date_timestamp')),
                                             Timezone(matches.group('authored_date_tzone'))),
                      Author(matches.group('committer_name'),
                             matches.group('committer_email')),
                      datetime.fromtimestamp(int(matches.group('committed_date_timestamp')),
                                             Timezone(matches.group('committed_date_tzone'))),
                      matches.group('message'),
                      parents)

    def parse_tag(self, raw):
        """
        Explicitly assumes that tag raw object is provided, then parses it
        and returns corresponding Tag object.
        If wrong raw is given, exception is thrown
        """

        if(raw.type != 'tag'):
            raise Exception('Provided raw is not a tag raw')

        matches = re.match('(object (?P<object>[0-9a-f]{40})\n)?' +
                           'type (?P<type>[a-z]+)\n' +
                           'tag (?P<tag>[^\n]+)\n'
                           'tagger (?P<tagger_name>[^<]*)' +
                               '(<(?P<tagger_email>[^>]+)>)? ' +
                               '(?P<tagged_date_timestamp>[0-9]+) ' +
                               '(?P<tagged_date_tzone>(\+|-)[0-9]{4})?\n' +
                           '\n(?P<message>.*)', raw.contents, re.DOTALL)

        if matches is None:
            raise Exception('Cannot parse raw as a tag raw')

        return Tag(raw.hash,
                   matches.group('object'),
                   matches.group('type'),
                   matches.group('tag'),
                   Author(matches.group('tagger_name'),
                          matches.group('tagger_email')),
                   datetime.fromtimestamp(int(matches.group('tagged_date_timestamp')),
                                          Timezone(matches.group('tagged_date_tzone'))),
                   matches.group('message')
                   )

    def parse_tree(self, raw):
        """
        Explicitly assumes that tree raw object is provided, then parses it
        and returns corresponding Tree object.
        If wrong raw is given, exception is thrown
        """

        if(raw.type != 'tree'):
            raise Exception('Provided raw is not a tree raw')

        nodes = []
        fields = re.findall('[^\000]+\000.{20}',
                            raw.contents, re.DOTALL)

        for field in fields:
            matches = re.match('(?P<filetype>[0-9]{2,3})' +
                               '(?P<mode>[0-9]{3}) ' +
                               '(?P<filename>[^\000]+)\000' +
                               '(?P<hash>.{20})',
                               field, re.DOTALL)
            node = dict(type = ('tree' if matches.group('filetype') == '40'
                                else 'blob'),
                        mode = int(matches.group('filetype') +
                                 matches.group('mode'), 8),
                        filename = matches.group('filename'),
                        hash = binascii.hexlify(matches.group('hash')))
            nodes.append(node)
        return Tree(raw.hash, nodes)

    def parse_blob(self, raw):
        """
        Explicitly assumes that blob raw object is provided, then parses it
        and returns corresponding Blob object.
        If wrong raw is given, exception is thrown
        """

        if(raw.type != 'blob'):
            raise Exception('Provided raw is not a blob raw')

        return Blob(raw.hash, raw.contents)


class Index(Parser):
    """
    Used to parse main .git index file and return it contents
    """
    def __init__(self, git_path):
        self.git_path = git_path
        super(Index, self)
        self.index_path = os.path.join(self.git_path, 'index')
        index_content = open(self.index_path, 'r').read()

        self.signature = self.__get_signature(index_content)
        self.version = self.__get_version(index_content)
        self.entries_num = self.__get_entries_num(index_content)
        self.entries = self.__get_entries(index_content)
        #TODO: last bytes (checksum ?)

    def __get_signature(self, index_content):
        """Returns signature of index file"""
        return index_content[0:4]

    def __get_version(self, index_content):
        """Returns version of index file"""
        return int(binascii.hexlify(index_content[4:8]), 16)

    def __get_entries_num(self, index_content):
        """Returns number of entries in index file"""
        return int(binascii.hexlify(index_content[8:12]), 16)

    def __get_entries(self, index_content):
        """Returns all parsed entries in index file as list of dictionaries"""
        entries_string = index_content[12:]
        entries = []
        start = 0
        end = 0
        entries_length = len(entries_string)
        while entries_length > (end + 62):
            end = int(start +
                      ceil((62 +
                                 entries_string[(start + 62):].find("\000") +
                                 1) /
                      8.0) * 8)
            entry_string = entries_string[start:end]
            flags = int(binascii.hexlify(entry_string[60:62]), 16)
            entry = dict(ctimes=int(binascii.hexlify(entry_string[0:4]), 16),
                         ctimen=int(binascii.hexlify(entry_string[4:8]), 16),
                         mtimes=int(binascii.hexlify(entry_string[8:12]), 16),
                         mtimen=int(binascii.hexlify(entry_string[12:16]), 16),
                         dev=int(binascii.hexlify(entry_string[16:20]), 16),
                         inode=int(binascii.hexlify(entry_string[20:24]), 16),
                         mode=int(binascii.hexlify(entry_string[24:28]), 16),
                         uid=int(binascii.hexlify(entry_string[28:32]), 16),
                         gid=int(binascii.hexlify(entry_string[32:36]), 16),
                         size=int(binascii.hexlify(entry_string[36:40]), 16),
                         sha1=binascii.hexlify(entry_string[40:60]),
                         flags = dict(assumeValid = (flags & 32768) >> 15,
                                         updateNeeded = (flags & 16384) >> 14,
                                         stage = (flags & 12288) >> 12,
                                         nameLength = (flags & 12287)),
                         filename = entry_string[62:].replace("\x00", ''))
            entries.append(entry)
            start = end
        return entries

class Config(Parser):

    def __init__(self, git_path):
        self.git_path = git_path
        self.config = ConfigParser.ConfigParser()
        stringio = StringIO(open(os.path.join(self.git_path, 'config')).read().replace("\t", ''))
        self.config.readfp(stringio)
    
    def __get_options(self, section):
        options = dict()
        for option in self.config.options(section):
            options[option] = self.config.get(section, option)
        return options
        
    
    @property
    def core(self):
        return self.__get_options('core')
        
    @property
    def branches(self):
        options = dict()
        for section in self.config.sections():
            if re.match('branch', section):
                options[section] = self.__get_options(section)
        return options
    
    def branch(self, name):
        return self.__get_options('branch "' + name + '"')
    
    @property
    def remotes(self):
        options = dict()
        for section in self.config.sections():
            if re.match('remote', section):
                options[section] = self.__get_options(section)
        return options
    
    def remote(self, name):
        return self.__get_options('remote "' + name + '"')
    
