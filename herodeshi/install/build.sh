#!/usr/bin/env bash
cp install.script /tmp/install.script
git fetch origin
git branch -u origin/gh-pages gh-pages
git checkout gh-pages
mv /tmp/install.script index.html
git add -A
git commit -m "Build timestamp: $(date)"
git push origin gh-pages
git checkout master

