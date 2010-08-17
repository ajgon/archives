import os.path

from pigit.parser import Parser
from pigit.gitobjects import Raw
from pigit.parser.delta import Delta
import binascii
import struct
import mmap


class Index(Parser):
    """
    Class used to parse index file to speed up pack file fetching.
    All indexes are contained in this object and are heavily used by Pack class
    """

    def __init__(self, hash):
        super(Index, self).__init__()
        self.hash = hash
        self.parse_index(open(os.path.join(self.git_path,
                                           'objects',
                                           'pack',
                                           'pack-' + hash + '.idx'),
                              'r').read())

    def parse_index(self, index_contents):
        """Fetch all necessary information from pack index file"""
        large_offsets = 0
        self.header = index_contents[0:4]
        self.version = struct.unpack('>L', index_contents[4:8])[0]

        self.fanouts = []
        for i in range(0, 256):
            self.fanouts.append(index_contents[(i*4 + 8):(i*4 + 12)])
        self.size = struct.unpack('>L', self.fanouts[255])[0]

        self.hashes = []
        for i in range(0, self.size):
            self.hashes.append(index_contents[(i*20 + 1032):(i*20 + 1052)])

        self.crcs = []
        for i in range(0, self.size):
            self.crcs.append(index_contents[(i*4 + 1032 + self.size * 20):
                                            (i*4 + 1036 + self.size * 20)])

        self.offsets = dict()
        for i in range(0, self.size):
            offset = index_contents[(i*4 + 1032 + self.size * 24):
                                    (i*4 + 1036 + self.size * 24)]
            self.offsets[self.hashes[i]] = struct.unpack('>L', offset)[0]
            if(ord(offset[0]) > 127):
                large_offsets += 1

        self.large_offsets = []
        for i in range(0, large_offsets):
            self.large_offsets.append(index_contents[(i*8 + 1032 + self.size * 28):
                                                     (i*8 + 1040 + self.size * 28)])

        self.pack_hash = index_contents[(1032 + self.size * 28 + large_offsets * 8):
                                        (1052 + self.size * 28 + large_offsets * 8)]
        self.index_hash = index_contents[(1052 + self.size * 28 + large_offsets * 8):
                                         (1072 + self.size * 28 + large_offsets * 8)]

class Pack(Parser):
    """Class used to walk through git pack files and fetch necessary objects"""

    OBJ_COMMIT = 1
    OBJ_TREE = 2
    OBJ_BLOB = 3
    OBJ_TAG = 4
    OBJ_OFS_DELTA = 6
    OBJ_REF_DELTA = 7

    def __init__(self, index):
        super(Pack, self).__init__()
        self.index = index
        self.packfile = os.path.join(self.git_path,
                                     'objects',
                                     'pack',
                                     'pack-' + self.index.hash + '.pack')
        FH = open(self.packfile, 'rb')
        self.mmap = mmap.mmap(FH.fileno(),
                              os.path.getsize(self.packfile),
                              mmap.MAP_PRIVATE,
                              mmap.PROT_READ)
        FH.close()
        self.NAMES = dict()
        self.NAMES[self.OBJ_COMMIT] = 'commit'
        self.NAMES[self.OBJ_TREE] = 'tree'
        self.NAMES[self.OBJ_BLOB] = 'blob'
        self.NAMES[self.OBJ_TAG] = 'tag'
        self.NAMES[self.OBJ_OFS_DELTA] = 'ofsdelta'
        self.NAMES[self.OBJ_REF_DELTA] = 'refdelta'

    def __del__(self):
        self.mmap.close()

    def read(self, hash):
        """
        Fetch object by given hash and return git Raw object
        corresponding to it
        """
        hex_hash = binascii.unhexlify(hash)
        if not self.index.offsets.has_key(hex_hash):
            return None
        self.mmap.seek(self.index.offsets[hex_hash])
        type, size = self.__read_header()
        if(type == self.OBJ_OFS_DELTA):
            type, contents = self.read_ofs_patched(hex_hash)
        elif(type == self.OBJ_REF_DELTA):
            type, contents = self.read_ref_patched(hex_hash)
        else:
            contents = self.uncompress_string(self.mmap.read(size + 11))
        return Raw(hash, self.NAMES[type], contents)

    def read_ofs_patched(self, hex_hash):
        """
        Fetch object by given hash and apply all deltas associated with it,
        then return patched raw object
        """
        type = self.OBJ_OFS_DELTA
        deltas = []
        pointer = self.index.offsets[hex_hash]
        while(type == self.OBJ_OFS_DELTA):
            self.mmap.seek(pointer)
            type, size = self.__read_header()
            if(type != self.OBJ_OFS_DELTA):
                break
            i      = 0
            c      = ord(self.mmap.read(1))
            offset = c & 127
            while((c & 128) == 128):
                i += 1
                c  = ord(self.mmap.read(1))
                offset += 1
                offset <<= 7
                offset |= c & 127
            pointer -= offset
            deltas.append(self.uncompress_string(self.mmap.read(size + 11)))
        deltas.reverse()
        if type == self.OBJ_REF_DELTA:
            type, base = self.read_ref_patched(None, pointer)
        else:
            base = self.uncompress_string(self.mmap.read(size + 11))
        for delta in deltas:
            base = Delta.patchObject(base, delta)
        return [type, base]

    def read_ref_patched(self, hex_hash, offset=None):
        """
        Fetch object by given hash and apply all deltas associated with it,
        then return patched raw object
        """
        type = self.OBJ_REF_DELTA
        deltas = []
        pointer = self.index.offsets[hex_hash] if not offset else offset
        while(type == self.OBJ_REF_DELTA):
            self.mmap.seek(pointer)
            type, size = self.__read_header()
            if(type != self.OBJ_REF_DELTA):
                break
            hash = self.mmap.read(20)
            pointer = self.index.offsets[hash]
            deltas.append(self.uncompress_string(self.mmap.read(size + 11)))
        base = self.uncompress_string(self.mmap.read(size + 11))
        for delta in deltas:
            base = Delta.patchObject(base, delta)
        return [type, base]

    def __read_header(self):
        """Read and parse pack data object header"""
        header  = ord(self.mmap.read(1))
        type    = (header >> 4) & 7
        hasnext = (header & 128) >> 7
        size    = header & 15
        offset  = 4
        while(hasnext == 1):
            byte    = ord(self.mmap.read(1))
            size   |= (byte & 127) << offset
            hasnext = (byte & 128) >> 7
            offset += 7
        return [type, size]
