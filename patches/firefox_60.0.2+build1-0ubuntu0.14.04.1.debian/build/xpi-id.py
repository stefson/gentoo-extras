#!/usr/bin/python

import sys
import json
import os
import zipfile

if __name__ == '__main__':
    if not len(sys.argv) == 2:
        print >> sys.stderr, "Must specify an xpi"
        exit(1)

    json_doc = json.loads(zipfile.ZipFile(sys.argv[1]).open('manifest.json').read().strip())
    gecko_id = json_doc["applications"]["gecko"]["id"]

    assert gecko_id
    print "%s" % gecko_id
    exit(0)
