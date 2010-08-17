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

    def __init__(self, repo_path, cache_time=900):
        git_path = os.path.join(repo_path, '.git')
        conf = Configuration()
        conf.git_path = git_path
        conf.gitcache = GitCache(cache_time)
        self.gitcache = conf.gitcache

        pack_files = glob.glob(os.path.join(git_path, 'objects', 'pack', 'pack-*.idx'))
        if(pack_files):
            conf.packs = [pack.Pack(pack.Index(re.search('-(?P<packhash>[a-f0-9]{40})\.idx', x).group('packhash'))) for x in pack_files]

        self.repo_path = repo_path
        self.ref = Ref()
        self.object = Object()
        self.parser = Parser()

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

    def history_first(self, path, commit=None):
        """
        Returns first commit where each of specified files
        matching :path changed (starting from :commit).
        """
        result = self.history(path, 1, commit)
        if(result.__class__.__name__ == 'dict'):
            return dict((x, result[x][0]) for x in result)
        else:
            return result[0]

    def history(self, path, limit=0, commit=None):
        """
        Returns :limit commits for each of files matching :path,
        starting from :commit, where given file changed.
        """
        item = self.gitcache.read(path, 'history' + str(limit))
        if(item):
            return item

        # First we need to check path, find wildcards and parse them properly
        # including hidden files
        commit = commit if commit else self.commit()
        self.__path_hash_parts = dict()
        new_path = path.strip(os.sep).split(os.sep)
        file = new_path[-1]
        dir = os.sep.join(new_path[:-1])
        tree_fields = self.parse(self.__find_path_hash_in_tree(commit.tree, re.sub('\/?[^/]+$', '', path).split(os.sep)), 'tree').fields
        files = [x['filename'] for x in tree_fields]
        isdir = re.search('([^\\\]\*|^\*)|' +
                          '([^\\\]\?|^\?)|' +
                          '([^\\\]\[|^\[)|' +
                          '([^\\\]\]|^\])', file) is not None

        # Now we determine, is it a tree contents of file itself
        if(isdir or files.__len__() > 1):
            result = self.history_tree(path, files, limit, commit)
        else:
            result = self.history_file(path, limit, commit)

        self.gitcache.store(path, result, 'history' + str(limit))
        return result

    def history_tree(self, path, files, limit=0, commit=None):
        """
        Fetches :limit of commits for all :files starting from :commit,
        where given file changed.
        """
        counts = dict()
        results = dict()
        hashes = dict()
        to_remove = []
        dirs_hashes = dict()
        commit = commit if commit else self.commit()
        tmp = path.split(os.sep)
        dirs = ['/'.join(tmp[0:i+1]) for i in range(0,tmp.__len__() - 1)]

        # First, we get all directories in a path hashes,
        # we will need them later
        for dir in dirs:
            dirs_hashes[dir] = self.__find_path_hash_in_tree(commit.tree,
                                                             dir.split(os.sep))

        # Next we set limits and initialize results list.
        # We also need base hashes (from first commit)
        for file in files:
            counts[file] = limit
            results[file] = []
            hashes[file] = self.__find_path_hash_in_tree(commit.tree,
                                                         file.split(os.sep))

        # Main loop, to walk through commits
        while(commit is not None):
            self.__path_hash_parts = dict()
            parent = commit.parent()
            if not parent:
                break

            # We check, that any of checked files changed. We do this,
            # by checking their parent trees. If files changed, their hashes
            # should also change. If they not, we don't go any further.
            break_while = False
            for dir in dirs:
                if self.__find_path_hash_in_tree(parent.tree, dir.split(os.sep)) == dirs_hashes[dir]:
                    commit = parent
                    break_while = True
                    break
            if(break_while):
                continue

            # If we have new file, we need to update dir hashes list
            for dir in dirs:
                dirs_hashes[dir] = self.__find_path_hash_in_tree(commit.tree,
                                                                 dir.split(os.sep))

            # Main loop for files, to check each of them for any changes.
            # If they do, we update they counter (we want only to fetch
            # :limit files) and add it to results table
            for file in files:
                if(counts[file] > -1):
                    hash_in_parent = self.__find_path_hash_in_tree(parent.tree,
                                                                   file.split(os.sep))
                    if(not hash_in_parent):
                        counts[file] = -1
                        results[file].append(commit)
                    elif(hash_in_parent != hashes[file]):
                        hashes[file] = hash_in_parent
                        results[file].append(commit)
                        if(limit != 0):
                            counts[file] -= 1
                            if(counts[file] == 0): counts[file] = -1

                # If we reached limit of commits,
                # remove file from checking list
                if(counts[file] == -1):
                    to_remove.append(file)

            for file in to_remove:
                files.remove(file)
            to_remove = []

            # After parsing all files, stop looping through commits
            if(files.__len__() == 0):
                break;
            commit = parent

        # If any of files left, it means, that they were added in first
        # commit, so we need to add them manually
        for file in files:
            results[file].append(commit)

        return results

    def history_file(self, path, limit=0, commit=None):
        """
        Fetches :limit of commits for file given identified by :path (filename)
        starting from :commit where given file changed.
        """
        return self.history_hash(self.get_path_hash(path, commit),
                                 limit,
                                 commit)

    def history_hash(self, hash, limit=0, commit=None):
        """
        Fetches :limit of commits for file given identified by :hash (hash)
        starting from :commit where given file changed.
        """
        commit = commit if commit else self.commit()
        commits = []

        path = self.__find_hash_path_in_tree(commit.tree, hash).split(os.sep)
        while(commit is not None):
            parent = commit.parent()
            if not parent:
                break
            hash_in_parent = self.__find_path_hash_in_tree(parent.tree, path)
            if(not hash_in_parent):
                break
            if(hash_in_parent != hash):
                hash = hash_in_parent
                commits.append(commit)
                if(limit != 0 and len(commits) >= limit):
                    break
            commit = parent

        if(len(commits) < limit and \
          (not commits or \
           (self.__find_path_hash_in_tree(commit.tree,
                                          (os.sep).join(path))))):
            commits.append(commit)
        return commits

    def get_hash_path(self, hash, commit=None):
        """
        Returns file path for given hash
        """
        commit = commit if commit else self.commit()
        return self.__find_hash_path_in_tree(commit.tree, hash)

    def get_path_hash(self, path, commit=None):
        """
        Returns hash for given file path
        """
        commit = commit if commit else self.commit()
        self.__path_hash_parts = dict()
        return self.__find_path_hash_in_tree(commit.tree,
                                             [part for part in path.split(os.sep) if part != ''])

    def fetch_file_hash(self, tree, path='', onlydirs=False):
        """
        Returns hashes for all files in specified :tree starting from :path
        """
        tf = tree.fields
        map = dict()
        for item in tf:
            item_path = os.path.join(path, item['filename'])
            if(item['type'] == 'tree'):
                map.update(self.fetch_file_hash(self.parse(item['hash']),
                                                item_path, onlydirs))
                map[item_path] = item['hash']
            elif(not onlydirs):
                map[item_path] = item['hash']
        return map

    def fetch_dir_hash(self, tree, path=''):
        """
        Returns hashes for all directories in specified :tree
        starting from :path
        """
        return self.fetch_file_hash(tree, path, True)

    def fetch_file_list(self, tree, path):
        """
        Returns list of all files in specified :tree starting from :path
        """
        return self.fetch_file_hash(tree, path, False).keys()

    def fetch_dir_list(self, tree, path):
        """
        Returns list of all directories in specified :tree starting from :path
        """
        return self.fetch_file_hash(tree, path, True).keys()

    def __find_hash_path_in_tree(self, tree, hash):
        tf = tree.fields
        for item in tf:
            if(item['type'] == 'tree' and item['hash'] != hash):
                result = self.__find_hash_path_in_tree(self.parse(item['hash']), hash)
                if result:
                    return item['filename'] + os.sep + result
            else:
                if(item['hash'] == hash):
                    return item['filename']

        return None

    def __find_path_hash_in_tree(self, tree, path):
        if path == ['']:
            return tree.hash
        tf = tree.fields
        for part in path:
            object = None
            for item in tf:
                if(item['filename'] == part):
                    object = item
                    break
            if(not object):
                return None
            if(self.__path_hash_parts.has_key(part) and \
               self.__path_hash_parts.has_key(path[-1]) and \
               self.__path_hash_parts[part] == object['hash']):
                return self.__path_hash_parts[path[-1]]

            path = path[1:]
            self.__path_hash_parts[part] = object['hash']
            if(object['type'] == 'tree' and path):
                return self.__find_path_hash_in_tree(self.parse(object['hash']), path)
            else:
                return object['hash']

    def __find_hash_in_tree(self, tree, hash):
        tf = tree.fields
        for item in tf:
            if(item['type'] == 'tree' and item['hash'] != hash):
                result = self.__find_hash_in_tree(self.parse(item['hash']), hash)
                if result:
                    return result
            else:
                if(item['hash'] == hash):
                    return self.parse(item['hash'])
        return None
