# -*- coding: ascii -*-
#
#  Util/asn1.py : Minimal support for ASN.1 DER binary encoding.
#
# ===================================================================
# The contents of this file are dedicated to the public domain.  To
# the extent that dedication to the public domain is not available,
# everyone is granted a worldwide, perpetual, royalty-free,
# non-exclusive license to exercise all rights associated with the
# contents of this file for any purpose whatsoever.
# No rights are reserved.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
# BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
# ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
# ===================================================================

import struct

from Crypto.Util.number import long_to_bytes, bytes_to_long

__all__ = [ 'DerObject', 'DerInteger', 'DerSequence' ]

class DerObject:
	typeTags = { 'SEQUENCE':'\x30', 'BIT STRING':'\x03', 'INTEGER':'\x02' }

	def __init__(self, ASN1Type=None):
		self.typeTag = self.typeTags.get(ASN1Type, ASN1Type)
		self.payload = ''

	def _lengthOctets(self, payloadLen):
		'''
		Return an octet string that is suitable for the BER/DER
		length element if the relevant payload is of the given
		size (in bytes).
		'''
		if payloadLen>127:
			encoding = long_to_bytes(payloadLen)
			return chr(len(encoding)+128) + encoding
		return chr(payloadLen)

	def encode(self):
		return self.typeTag + self._lengthOctets(len(self.payload)) + self.payload	

	def _decodeLen(self, idx, str):
		'''
		Given a string and an index to a DER LV,
		this function returns a tuple with the length of V
		and an index to the first byte of it.
		'''
		length = ord(str[idx])
		if length<=127:
			return (length,idx+1)
		else:
			payloadLength = bytes_to_long(str[idx+1:idx+1+(length & 0x7F)])
			if payloadLength<=127:
				raise ValueError("Not a DER length tag.")
			return (payloadLength, idx+1+(length & 0x7F))

	def decode(self, input, noLeftOvers=0):
		try:
			self.typeTag = input[0]
			if (ord(self.typeTag) & 0x1F)==0x1F:
				raise ValueError("Unsupported DER tag")
			(length,idx) = self._decodeLen(1,input)
			if noLeftOvers and len(input) != (idx+length):
				raise ValueError("Not a DER structure")
			self.payload = input[idx:idx+length]
		except IndexError:
			raise ValueError("Not a valid DER SEQUENCE.")
		return idx+length

class DerInteger(DerObject):
	def __init__(self, value = 0):
		DerObject.__init__(self, 'INTEGER')
		self.value = value

	def encode(self):
		self.payload = long_to_bytes(self.value)
		if ord(self.payload[0])>127:
			self.payload = '\x00' + self.payload
		return DerObject.encode(self)

	def decode(self, input, noLeftOvers=0):
		tlvLength = DerObject.decode(self, input,noLeftOvers)
		if ord(self.payload[0])>127:
			raise ValueError ("Negative INTEGER.")
		self.value = bytes_to_long(self.payload)
		return tlvLength
				
class DerSequence(DerObject):
	def __init__(self):
		DerObject.__init__(self, 'SEQUENCE')
		self._seq = []
	def __delitem__(self, n):
		del self._seq[n]
	def __getitem__(self, n):
		return self._seq[n]
	def __setitem__(self, key, value):
		self._seq[key] = value	
	def __setslice__(self,i,j,sequence):
		self._seq[i:j] = sequence
	def __delslice__(self,i,j):
		del self._seq[i:j]
	def __getslice__(self, i, j):
		return self._seq[max(0, i):max(0, j)]
	def __len__(self):
		return len(self._seq)
	def append(self, item):
		return self._seq.append(item)

	def hasOnlyInts(self):
		if not self._seq: return 0
		test = 0
		for item in self._seq:
			try:
				test += item
			except TypeError:
				return 0
		return 1

	def encode(self):
		'''
		Return the DER encoding for the ASN.1 SEQUENCE containing
		the non-negative integers and longs added to this object.
		'''
		self.payload = ''
		for item in self._seq:
			try:
				self.payload += item
			except:
				try:
					self.payload += DerInteger(item).encode()
				except:
					raise ValueError("Trying to DER encode an unknown object")
		return DerObject.encode(self)

	def decode(self, input,noLeftOvers=0):
		'''
		This function decodes the given string into a sequence of
		ASN.1 objects. Yet, we only know about unsigned INTEGERs.
		Any other type is stored as its rough TLV. In the latter
		case, the correctectness of the TLV is not checked.
		'''
		self._seq = []
		try:
			tlvLength = DerObject.decode(self, input,noLeftOvers)
			if self.typeTag!=self.typeTags['SEQUENCE']:
				raise ValueError("Not a DER SEQUENCE.")
			# Scan one TLV at once
			idx = 0
			while idx<len(self.payload):
				typeTag = self.payload[idx]
				if typeTag==self.typeTags['INTEGER']:
					newInteger = DerInteger()
					idx += newInteger.decode(self.payload[idx:])
					self._seq.append(newInteger.value)
				else:
					itemLen,itemIdx = self._decodeLen(idx+1,self.payload)
					self._seq.append(self.payload[idx:itemIdx+itemLen])
					idx = itemIdx + itemLen
		except IndexError:
			raise ValueError("Not a valid DER SEQUENCE.")
		return tlvLength


class BERException (Exception):
	pass


class BER(object):
	"""
Robey's tiny little attempt at a BER decoder.
"""

	def __init__(self, content=''):
		self.content = content
		self.idx = 0

	def __str__(self):
		return self.content

	def __repr__(self):
		return 'BER(\'' + repr(self.content) + '\')'

	def decode(self):
		return self.decode_next()
	
	def decode_next(self):
		if self.idx >= len(self.content):
			return None
		ident = ord(self.content[self.idx])
		self.idx += 1
		if (ident & 31) == 31:
			# identifier > 30
			ident = 0
			while self.idx < len(self.content):
				t = ord(self.content[self.idx])
				self.idx += 1
				ident = (ident << 7) | (t & 0x7f)
				if not (t & 0x80):
					break
		if self.idx >= len(self.content):
			return None
		# now fetch length
		size = ord(self.content[self.idx])
		self.idx += 1
		if size & 0x80:
			# more complimicated...
			# FIXME: theoretically should handle indefinite-length (0x80)
			t = size & 0x7f
			if self.idx + t > len(self.content):
				return None
			size = self.__inflate_long(self.content[self.idx : self.idx + t], True)
			self.idx += t
		if self.idx + size > len(self.content):
			# can't fit
			return None
		data = self.content[self.idx : self.idx + size]
		self.idx += size
		# now switch on id
		if ident == 0x30:
			# sequence
			return self.decode_sequence(data)
		elif ident == 2:
			# int
			return self.__inflate_long(data)
		else:
			# 1: boolean (00 false, otherwise true)
			raise BERException('Unknown ber encoding type %d (robey is lazy)' % ident)

	def decode_sequence(data):
		out = []
		b = BER(data)
		while True:
			x = b.decode_next()
			if x is None:
				break
			out.append(x)
		return out
	decode_sequence = staticmethod(decode_sequence)

	def encode_tlv(self, ident, val):
		# no need to support ident > 31 here
		self.content += chr(ident)
		if len(val) > 0x7f:
			lenstr = self.__deflate_long(len(val))
			self.content += chr(0x80 + len(lenstr)) + lenstr
		else:
			self.content += chr(len(val))
		self.content += val

	def encode(self, x):
		if type(x) is bool:
			if x:
				self.encode_tlv(1, '\xff')
			else:
				self.encode_tlv(1, '\x00')
		elif (type(x) is int) or (type(x) is long):
			self.encode_tlv(2, self.__deflate_long(x))
		elif type(x) is str:
			self.encode_tlv(4, x)
		elif (type(x) is list) or (type(x) is tuple):
			self.encode_tlv(0x30, self.encode_sequence(x))
		else:
			raise BERException('Unknown type for encoding: %s' % repr(type(x)))

	def encode_sequence(data):
		b = BER()
		for item in data:
			b.encode(item)
		return str(b)
	encode_sequence = staticmethod(encode_sequence)

	def __inflate_long(self, s, always_positive=False):
		out = 0L
		negative = 0
		if not always_positive and (len(s) > 0) and (ord(s[0]) >= 0x80):
			negative = 1
		if len(s) % 4:
			filler = '\x00'
			if negative:
				filler = '\xff'
			s = filler * (4 - len(s) % 4) + s
		for i in range(0, len(s), 4):
			out = (out << 32) + struct.unpack('>I', s[i:i+4])[0]
		if negative:
			out -= (1L << (8 * len(s)))
		return out
	
	def __deflate_long(self, n, add_sign_padding=True):
		s = ''
		n = long(n)
		while (n != 0) and (n != -1):
			s = struct.pack('>I', n & 0xffffffffL) + s
			n = n >> 32
		# strip off leading zeros, FFs
		for i in enumerate(s):
			if (n == 0) and (i[1] != '\000'):
				break
			if (n == -1) and (i[1] != '\xff'):
				break
		else:
			# degenerate case, n was either 0 or -1
			i = (0,)
			if n == 0:
				s = '\000'
			else:
				s = '\xff'
		s = s[i[0]:]
		if add_sign_padding:
			if (n == 0) and (ord(s[0]) >= 0x80):
				s = '\x00' + s
			if (n == -1) and (ord(s[0]) < 0x80):
				s = '\xff' + s
		return s