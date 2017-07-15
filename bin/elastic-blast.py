#!/usr/bin/env python

# Copyright (c) 2014 Anchor Systems

# https://github.com/anchor/elasticsearch-scripts

"""
NAME

    es-nuke-all-indices - destroy all data in the cluster


SYNOPSIS

    es-nuke-all-indices [HOST[:PORT]]


DESCRIPTION

    Connect to the ElasticSearch HTTP server at HOST:PORT (defaults to 
    localhost:9200), and submit a synchronous API request to delete all 
    indices. 

    Consequently, this will IRREVERSIBLY DESTROY ALL DATA IN THE CLUSTER.

"""
DEFAULT_HOST = "localhost"
DEFAULT_PORT = 9200

from esadmin import Connection
import logging
import os
import socket
import sys
import json
import re
import optparse

logger = logging.getLogger(__name__)

def main(argv=None):
    host = DEFAULT_HOST
    port = DEFAULT_PORT

    
    parser = optparse.OptionParser(usage="%prog --i-know-what-i-am-doing [HOST:PORT]\n"
                                         "This will irreversably delete ALL data in the cluster.")

    parser.add_option("--i-know-what-i-am-doing", 
                      dest="proceed",
                      help="Actually delete all indices.",
                      action="store_true")

    opts, args = parser.parse_args()
    if not opts.proceed:
        parser.print_usage()
        return 3

    try:
        address = args[0]
    except IndexError:
        pass
    else:
        if address.find(":") == -1:
            host = address
        else:
            host, port = address.split(":")
            try:
                port = int(port)
            except ValueError:
                parser.print_usage()
                return 2

    logger.info("Deleting all data in all indices in the cluster.")

    with Connection(host, port) as conn:
        resp = conn.delete('/_all')

    logger.info("Deleted all indices.")

    return 0

if __name__ == '__main__':
    hostname = socket.gethostname()
    fmt = ('[%s] [%%(process)d]: [%%(levelname)s] '
           '%%(message)s' % hostname)
    logging.basicConfig(level=logging.INFO, format=fmt)

    sys.exit(main(sys.argv))
