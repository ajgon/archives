class Raw(object):
    """Raw git object - only contains it's hash, type and contents"""

    def __init__(self, hash, type, contents):
        self.hash = hash
        self.type = type
        self.contents = contents


class Commit(object):
    """Commit container - contains all information about commit"""

    def __init__(self, hash, tree, author, authored_date, committer,
                 committed_date, message, parents_hashes=[]):
        self.hash = hash
        self._tree = tree
        self.author = author
        self.authored_date = authored_date
        self.committer = committer
        self.committed_date = committed_date
        self.message = message
        self.parents_hashes = parents_hashes

    def parent(self, index=0):
        """Returns parent of this commit - another Commit object"""
        from pigit.parser import Parser
        if len(self.parents_hashes) > index:
            return Parser().parse(self.parents_hashes[index], 'commit')
        else:
            return None

    def parents(self):
        """Returns list of all commit parents containing Commit objects"""
        from pigit.parser import Parser
        commits = []
        for parent_hash in self.parents_hashes:
            commits.append(Parser().parse(parent_hash, 'commit'))
        return commits

    @property
    def tree(self):
        """Returns Tree object associated with this commit"""
        from pigit.parser import Parser
        return Parser().parse(self._tree, 'tree')


class Author(object):
    """Author container - contains all information about author"""

    def __init__(self, name, email):
        self.name = name
        self.email = email


class Tag(object):
    """Tag container - contains all information about tag"""

    def __init__(self, hash, object_hash, type, tag,
                 tagger, tagged_date, message):
        self.hash = hash
        self._object = object_hash
        self.type = type
        self.tag = tag
        self.tagger = tagger
        self.tagged_date = tagged_date
        self.message = message
        if(type == 'commit'):
            self.parents_hashes = [object_hash]
            self.authored_date = tagged_date

    @property
    def object(self):
        """Returns object associated with this tag"""
        from pigit.parser import Parser
        return Parser().parse(self._object)


class Tree(object):
    """Tree container - contains all information about tree"""

    def __init__(self, hash, fields, mode=None, filename=None):
        self.hash = hash
        self.fields = fields
        self.mode = mode
        self.filename = filename

    @property
    def contents(self):
        """Returns all the Tree/Blob objects connected to this tree"""
        from pigit.parser import Parser
        contents = []
        for field in self.fields:
            content = Parser().parse(field['hash'])
            content.mode = field['mode']
            content.filename = field['filename']
            contents.append(content)

        return contents


class Blob(object):
    """Blob container contains all information about blob"""

    def __init__(self, hash, contents, mode=None, filename=None):
        self.hash = hash
        self.contents = contents
        self.mode = mode
        self.filename = filename
