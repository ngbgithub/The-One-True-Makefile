##########################################################
# Define some useful variables.
##########################################################

# *.hpp files that aren't going to be installed should not be
# mentioned anywhere in the module.mk.
foo_src := \
	foo/src/foo.cpp		\
	foo/src/hello.cpp

foo_bins := $(stage_dir)/bin/foo

foo_etcs :=

foo_includes :=

foo_libs :=

foo_shares := $(stage_dir)/share/$(PKG_NAME)/foo/hello.xml

foo_obj := \
	$(addprefix $(build_dir)/foo/,\
		$(notdir $(foo_src:.cpp=.lo)))

foo_prod := \
	$(foo_bins) \
	$(foo_etcs) \
	$(foo_includes) \
	$(foo_libs) \
	$(foo_shares)

# Dependency files:
foo_deps := \
	$(addsuffix .d,$(basename $(foo_src)))

foo_cppflags := -Iinclude -Itinyxml2/include

##########################################################
# Add to our list of what the Makefile manages.
##########################################################

SRC += $(foo_src)
BIN_INSTALL_LIST += $(foo_bins)
ETC_INSTALL_LIST += $(foo_etcs)
INCLUDE_INSTALL_LIST +=$(foo_includes)
LIB_INSTALL_LIST +=$(foo_libs)
SHARE_INSTALL_LIST += $(foo_shares)

##########################################################
# Dependencies and rules:
##########################################################

$(foo_deps): CPPFLAGS += $(foo_cppflags)
$(foo_deps): foo/module.mk

$(foo_obj): CPPFLAGS += $(foo_cppflags)

# This implicit rule works because foo.cpp is the first in the
#   $(foo_src) list, which means it's first in the $(foo_obj) list.
# Note that make is smart enough to see -ltinyxml2-otm and know it has
#   to build $(stage_dir)/lib/libtinyxml2-otm.so, through the magic of
#   vpath directives.
# If we felt it were helpful, we might add an order-only dependency
#   for hello.xml since it's required at runtime, although it's not
#   necessary if all we're going to do is "make foo" and not "make
#   Linux-stage/bin/foo".
$(stage_dir)/bin/foo: \
	$(foo_obj) -ltinyxml2-otm \
	| $(stage_dir)/bin

##########################################################
# Phony targets:
##########################################################

foo: $(foo_prod)

