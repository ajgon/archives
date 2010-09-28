import os.path
import fnmatch
import re
import glob

from pigit.parser.ref import Ref
from pigit.parser.object import Object
from pigit.common import Configuration
from pigit.common import GitCache
from pigit.parser import Parser
from pigit.parser import pack
from datetime import datetime


class Pigit(object):
    """
    Main core class used to end communication with user
    """

    def __init__(self, repo_path):

        self.repo_path = repo_path
        conf = Configuration()
        conf.git_path = os.path.join(repo_path, '.git')
        
        if not Pigit.is_repo(repo_path):
            raise IOError('Provided directory is not a git repository: \'' + repo_path + '\'')
        
        pack_files = glob.glob(os.path.join(conf.git_path, 'objects', 'pack', 'pack-*.idx'))
        if(pack_files):
            conf.packs = [pack.Pack(pack.Index(re.search('-(?P<packhash>[a-f0-9]{40})\.idx', x).group('packhash'))) for x in pack_files]

        self.ref = Ref()
        self.object = Object()
        self.parser = Parser()
        
    @staticmethod
    def is_repo(repo_path):
        return os.path.exists(os.path.join(repo_path, '.git'))

    def log(self, hash=None, limit=0, src=None, dst=None):
        if(hash is None):
            if(src is None):
                hash = self.ref.head_hash()
            else:
                hash = src
        else:
            hash = hash

        if(src and dst):
            limit = self.__commit_distance(self.parse(src, 'commit'), self.parse(dst, 'commit'))
            print limit
            if(limit == 0):
                return []
            if(limit < 0):
                hash = dst
                limit = limit * -1
                
        commit = self.parse(hash, 'commit')
        hashes = []
        loop = (limit == 0)
        while (loop or limit > 0):
            parent = commit.parent()
            if not parent:
                break
            hashes.append(self.diff_trees(commit.tree, commit.parent().tree))
            commit = parent
            limit = limit - 1
            
        return hashes

    def diff_trees(self, src_tree, dst_tree):
        src_tree_fields = dict((x['filename'], dict(hash=x['hash'], type=x['type'])) for x in src_tree.fields) 
        dst_tree_fields = dict((x['filename'], dict(hash=x['hash'], type=x['type'])) for x in dst_tree.fields)
        all_tree_fields = src_tree_fields
        all_tree_fields.update(dict([(item,dst_tree_fields[item]) for item in dst_tree_fields.keys() if not src_tree_fields.has_key(item)]))

        results = []

        for item in all_tree_fields:
            if(not src_tree_fields.has_key(item) or not dst_tree_fields.has_key(item)):
                results.append(item)
                continue
            
            if(src_tree_fields[item]['hash'] != dst_tree_fields[item]['hash']):
                if(all_tree_fields[item]['type'] == 'tree'):
                    res = self.diff_trees(self.parse(src_tree_fields[item]['hash'], 'tree'), self.parse(dst_tree_fields[item]['hash'], 'tree'))
                    for file in res:
                        results.append(item + os.sep + file)
                else:
                    results.append(item)

        return results

    def commit(self, hash=None):
        """Returns commit object (HEAD commit if hash is no provided)"""
        hash = self.ref.head_hash() if(hash is None) else hash
        return self.parse(hash, 'commit')

    def commits(self, ref='master', limit=0, page=0):
        """
        Returns last :limit git commits from branch :branch starting from :page
        If limit is 0, returns all
        """
        stack = [self.ref.head_hash(ref)]
        commits = dict()
        iteration = 0
        while(len(stack) > 0 and (iteration < limit + page or limit == 0)):
            iteration += 1
            hash = stack.pop()
            if(hash not in commits):
                commit = self.commit(hash)
                if(iteration > page):
                    commits[hash] = commit
                stack = list(set(stack + commit.parents_hashes))

        return sorted(commits.values(),
                      key=lambda commit: commit.authored_date,
                      reverse=True)

    def tree(self, hash):
        """Returns tree object"""
        return self.parse(hash, 'tree')

    def blob(self, hash):
        """Returns blob object"""
        return self.parse(hash, 'blob')

    def tag(self, hash):
        """Returns tag object"""
        return self.parse(hash, 'tag')

    def parse(self, hash, type=None):
        """Returns object associated with given hash"""
        return self.parser.parse(hash, type)

    def __commit_distance(self, src, dst):
        commit = self.commit()
        parent = commit.parent()
        distance = 0
        multipier = 0
        while(parent):
            parent = commit.parent()
            if(multipier != 0):
                distance = distance + 1
                
            if(commit.hash == src.hash):
                if(multipier != 0):
                    break
                else:
                    multipier = 1
                
            if(commit.hash == dst.hash):
                if(multipier != 0):
                    break
                else:
                    multipier = -1
            commit = parent
                    
        distance = distance * multipier
        return distance
