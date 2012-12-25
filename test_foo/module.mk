##########################################################
# Define some useful variables.
##########################################################

test_foo_src := \
	test_foo/src/test_foo_word0.cpp	\
	test_foo/src/test_foo_word1.cpp

test_foo_bins := \
	$(test_dir)/bin/test_foo_word0 \
	$(test_dir)/bin/test_foo_word1 \
	$(test_dir)/bin/test_foo.py

test_foo_etcs :=

test_foo_includes :=

test_foo_libs :=

test_foo_shares := $(test_dir)/share/$(PKG_NAME)/foo/hello.xml

test_foo_obj := \
	$(addprefix $(build_dir)/test_foo/,\
		$(notdir $(test_foo_src:.cpp=.lo)))

test_foo_prod := \
	$(test_foo_bins) \
	$(test_foo_etcs) \
	$(test_foo_includes) \
	$(test_foo_libs) \
	$(test_foo_shares)

# Dependency files:
test_foo_deps := \
	$(addsuffix .d,$(basename $(test_foo_src)))

test_foo_cppflags := -Iinclude -Ifoo/src

##########################################################
# Add to our list of what the Makefile manages.
##########################################################

# Binaries etc. don't get added to these lists, sine unit tests don't
#   get installed.

SRC += $(test_foo_src)
BIN_INSTALL_LIST +=
ETC_INSTALL_LIST +=
INCLUDE_INSTALL_LIST +=
LIB_INSTALL_LIST +=
SHARE_INSTALL_LIST +=

##########################################################
# Dependencies and rules:
##########################################################

# The hello.lo functions expect the xml file to be in
#   $(test_dir)/bin/../share/$(PKG_NAME)/foo.  The makefile is smart
#   enough to deal with $(test_dir)/share/$(PKG_NAME)/test_foo/*.xml
#   implicitly, but since hello.lo expects the xml file to be in
#   $(test_dir)/share/$(PKG_NAME)/foo and *not* in test_fo, we have to
#   deal with the xml file manually here.  (We also have to deal with
#   creating the directory manually.)

fooDir := $(test_dir)/share/$(PKG_NAME)/foo
$(test_dir)/share/$(PKG_NAME)/foo/hello.xml: \
	foo/share/$(PKG_NAME)/foo/hello.xml \
	| $(fooDir)

$(fooDir):
	mkdir -p $@

$(test_foo_deps): CPPFLAGS += $(test_foo_cppflags)
$(test_foo_deps): test_foo/module.mk

$(test_foo_obj): CPPFLAGS += $(test_foo_cppflags)

$(test_dir)/bin/test_foo_word0: \
	$(build_dir)/test_foo/test_foo_word0.lo \
	$(build_dir)/foo/hello.lo \
	-ltinyxml2-otm \
	| $(test_dir)/bin

$(test_dir)/bin/test_foo_word1: \
	$(build_dir)/test_foo/test_foo_word1.lo \
	$(build_dir)/foo/hello.lo \
	-ltinyxml2-otm \
	| $(test_dir)/bin

##########################################################
# Phony targets:
##########################################################

test_foo: $(test_foo_prod)

clobber: clobber_test_foo

.PHONY: clobber_test_foo
clobber_test_foo:
	$(LIBTOOL) --mode=clean $(RM) $(test_foo_prod)
	@[ ! -d $(fooDir) ] || echo rmdir $(fooDir)
	@[ ! -d $(fooDir) ] ||      rmdir $(fooDir)
