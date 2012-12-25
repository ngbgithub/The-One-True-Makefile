##########################################################
# Define some useful variables.
##########################################################

test_tinyxml2_src := test_tinyxml2/src/xmltest.cpp

test_tinyxml2_bins := \
	$(test_dir)/bin/xmltest \
	$(test_dir)/bin/test_tinyxml2.py

test_tinyxml2_etcs :=

test_tinyxml2_includes :=

test_tinyxml2_libs :=

test_tinyxml2_shares := \
	$(test_dir)/share/$(PKG_NAME)/test_tinyxml2/resources/dream.xml \
      $(test_dir)/share/$(PKG_NAME)/test_tinyxml2/resources/utf8testverify.xml \
	$(test_dir)/share/$(PKG_NAME)/test_tinyxml2/resources/utf8test.xml

test_tinyxml2_obj := \
	$(addprefix $(build_dir)/test_tinyxml2/,\
		$(notdir $(test_tinyxml2_src:.cpp=.lo)))

test_tinyxml2_prod := \
	$(test_tinyxml2_bins) \
	$(test_tinyxml2_etcs) \
	$(test_tinyxml2_includes) \
	$(test_tinyxml2_libs) \
	$(test_tinyxml2_shares)

# Dependency files:
test_tinyxml2_deps := \
	$(addsuffix .d,$(basename $(test_tinyxml2_src)))

test_tinyxml2_cppflags := -Itinyxml2/include

##########################################################
# Add to our list of what the Makefile manages.
##########################################################

# Binaries etc. don't get added to these lists, since unit tests don't
#   get installed.

SRC += $(test_tinyxml2_src)
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
#   enough to deal with $(test_dir)/share/$(PKG_NAME)/test_tinyxml2/*.xml
#   implicitly, but since hello.lo expects the xml file to be in
#   $(test_dir)/share/$(PKG_NAME)/foo and *not* in test_foo, we have to
#   deal with the xml file manually here.  (We also have to deal with
#   creating the directory manually.)

$(test_tinyxml2_deps): CPPFLAGS += $(test_tinyxml2_cppflags)
$(test_tinyxml2_deps): test_tinyxml2/module.mk

$(test_tinyxml2_obj): CPPFLAGS += $(test_tinyxml2_cppflags)

#$(test_dir)/bin/xmltest: LDFLAGS += -L$(stage_dir)/lib
$(test_dir)/bin/xmltest: \
	$(build_dir)/test_tinyxml2/xmltest.lo \
	-ltinyxml2-otm \
	| $(test_dir)/bin

$(test_tinyxml2_shares): $(test_dir)/share/$(PKG_NAME)/test_tinyxml2/resources

$(test_dir)/share/$(PKG_NAME)/test_tinyxml2/resources:
	mkdir $@

##########################################################
# Phony targets:
##########################################################

test_tinyxml2: $(test_tinyxml2_prod)

clobber: clobber_test_tinyxml2

.PHONY: clobber_test_tinyxml2
clobber_test_tinyxml2:
	$(LIBTOOL) --mode=clean $(RM) $(test_tinyxml2_prod)

