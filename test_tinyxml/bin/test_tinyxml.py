#!/usr/bin/env python

from __future__ import print_function

import contextlib, os, subprocess, unittest


class TestTinyXML(unittest.TestCase):

    def test_xmltest(self):

        # We start out in the $(test_dir)/bin directory, but out input
        #   files are in $(test_dir)/share/$(PKG_NAME)/tinymxl, so we
        #   need to find that directory and temporarily switch into
        #   it.
        path = _findShareSubdir()
        with _change_dir_back_when_done(path):

            cmd = ['../../../bin/xmltest']
            p = subprocess.Popen(cmd, stdout=subprocess.PIPE)
            try:
                o, e = p.communicate()
                expected = o.split(b'\n')[-2]

            # Kill the output files xmltest generates.
            finally:
                for f in ['file.txt', 'textfile.txt']:
                    if os.path.exists(f):
                        os.remove(f)

        self.assertEqual(expected, b'Pass 136, Fail 0',
                         b'Unexpected output: '+o)


@contextlib.contextmanager
def _change_dir_back_when_done(path):
    '''Restore the original directory when we're done, even if there's
    an error, in a clean way.
    '''
    orig = os.getcwd()
    try:
        os.chdir(path)
        yield 1
    finally:
        os.chdir(orig)


def _findShareSubdir():
    '''Find our test_tinyxml subdirectory of ../share.  (This is
    useful because I don't want to deal with hard coding a package
    name.)
    '''
    path = None
    for d in os.walk('..'):
        spl = d[0].split('/')
        if (len(spl) > 1) and (spl[1] == 'share') \
                and (spl[-1] == 'test_tinyxml'):
            path = d[0]
            break
    if path is None:
        raise Exception('Appropriate subdirectory of $(test_dir)/share not'
                        ' found')

    return path

