# This bit of hackiness is a workaround for the weird ass "error:
#   specify a tag with --tag" error.
export LIBTOOL="glibtool --tag=CXX"

prefix=$HOME/.opt/one_true_makefile

./configure \
    --prefix=$prefix

