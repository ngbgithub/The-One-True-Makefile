#!/usr/bin/env python

from __future__ import print_function

import contextlib, os, shutil, subprocess, unittest


class TestTinyXML2(unittest.TestCase):

    def test_xmltest(self):

        # We start out in the $(test_dir)/bin directory, but out input
        #   files are in $(test_dir)/share/$(PKG_NAME)/tinymxl, so we
        #   need to find that directory and temporarily switch into
        #   it.

        # Create our temp directory, and populate it.
        with _tempDir() as tempDir:
            targetDir = os.path.join(tempDir, 'resources')
            os.mkdir(targetDir, 0o777)
            resourcesParentDir = _findShareSubdir('..')
            for b in ('dream.xml', 'utf8testverify.xml', 'utf8test.xml'):
                f = os.path.join(resourcesParentDir, 'resources', b)
                shutil.copy(f, targetDir)

            # Change into our temp dir, and run our test.
            cmd = [os.path.abspath('xmltest')]
            with _change_dir_back_when_done(tempDir):
                p = subprocess.Popen(cmd, stdout=subprocess.PIPE)
                o, e = p.communicate()
                summary = o.split(b'\n')[-2]

        self.assertEqual(summary, b'Pass 101, Fail 0',
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


@contextlib.contextmanager
def _tempDir():
    '''Create a temp directory, and delete it when we're done.
    '''
    import tempfile

    try:
        d = tempfile.mkdtemp()
        yield d
    finally:
        shutil.rmtree(d)


def _findShareSubdir(prefix):
    '''Find our test_tinyxml2 subdirectory of ../share.  (This is
    useful because I don't want to deal with hard coding a package
    name.)
    '''
    path = None
    for d in os.walk(prefix):
        spl = d[0].split('/')
        if (len(spl) > 1) and (spl[1] == 'share') \
                and (spl[-1] == 'test_tinyxml2'):
            path = d[0]
            break
    if path is None:
        raise Exception('Appropriate subdirectory of $(test_dir)/share not'
                        ' found')

    return path

