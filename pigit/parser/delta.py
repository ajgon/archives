class Delta(object):
    """Class used to apply deltas to base files"""

    @staticmethod
    def patchDeltaHeaderSize(delta, pos):
        size = shift = 0
        byte = 128
        while((byte & 128) != 0):
            byte = ord(delta[pos])
            pos += 1
            size |= (byte & 127) << shift
            shift += 7

        return [size, pos]

    @staticmethod
    def patchObject(base, delta):
        src_size, pos = Delta.patchDeltaHeaderSize(delta, 0)
        if(src_size != len(base)):
            raise Exception('Invalid delta data size')
        dst_size, pos = Delta.patchDeltaHeaderSize(delta, pos)

        dest = ''
        delta_size = len(delta)
        while(pos < delta_size):
            byte = ord(delta[pos])
            pos += 1
            if((byte & 128) != 0):
                pos -= 1
                cp_off = cp_size = 0
                # Fetch start position
                flags = (1, 2, 4, 8)
                for i in range(0,4):
                    if((byte & flags[i]) != 0):
                        pos += 1
                        cp_off |= ord(delta[pos]) << (i * 8)
                # Fetch length
                flags = (16, 32, 64)
                for i in range(0,3):
                    if((byte & flags[i]) != 0):
                        pos += 1
                        cp_size |= ord(delta[pos]) << (i * 8)
                # Default length
                if(cp_size == 0):
                    cp_size = 65536
                part = base[cp_off:(cp_off+cp_size)]
                if(len(part) != cp_size):
                    raise Exception('Patching error: expecting ' + str(cp_size)
                                    + ' bytes but only got ' + str(len(part)))
                pos += 1
            elif(byte != 0):
                part = delta[pos:(pos+byte)]
                if(len(part) != byte):
                    raise Exception('Patching error: expecting ' + str(byte) +
                                    ' bytes but only got ' + str(len(part)))
                pos += byte
            else:
                raise Exception('Invalid delta data at position ' + str(pos))
            dest += part
        if(len(dest) != dst_size):
            raise Exception('Patching error: Expected size and ' +
                            'patched size mismatch')

        return dest
