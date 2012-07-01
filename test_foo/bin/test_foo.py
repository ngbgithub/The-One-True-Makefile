#!/usr/bin/env python

import subprocess, unittest


class TestPmwebsockd(unittest.TestCase):

    # NOTE: All paths are relative to the $(test_dir)/bin directory.

    def test_foo_word0(self):
        cmd = ['./test_foo_word0']
        p = subprocess.Popen(cmd, stdout=subprocess.PIPE)
        o, e = p.communicate()
        self.assertEqual(o, b'Hello\n',
                         b'Unexpected output: '+o)

    def test_foo_word1(self):
        cmd = ['./test_foo_word1']
        p = subprocess.Popen(cmd, stdout=subprocess.PIPE)
        o, e = p.communicate()
        self.assertEqual(o, b'world\n',
                         b'Unexpected output: '+o)

