##########################################################
# Define some useful variables.
##########################################################

test_tinyxml_src := test_tinyxml/src/xmltest.cpp

test_tinyxml_bins := \
	$(test_dir)/bin/xmltest \
	$(test_dir)/bin/test_tinyxml.py

test_tinyxml_etcs :=

test_tinyxml_includes :=

test_tinyxml_libs :=

test_tinyxml_shares := \
	$(test_dir)/share/$(PKG_NAME)/test_tinyxml/demotest.xml \
	$(test_dir)/share/$(PKG_NAME)/test_tinyxml/test5.xml \
	$(test_dir)/share/$(PKG_NAME)/test_tinyxml/test6.xml \
	$(test_dir)/share/$(PKG_NAME)/test_tinyxml/test7.xml \
	$(test_dir)/share/$(PKG_NAME)/test_tinyxml/utf8testout.xml \
	$(test_dir)/share/$(PKG_NAME)/test_tinyxml/utf8testverify.xml \
	$(test_dir)/share/$(PKG_NAME)/test_tinyxml/utf8test.xml

test_tinyxml_obj := \
	$(addprefix $(build_dir)/test_tinyxml/,\
		$(notdir $(test_tinyxml_src:.cpp=.lo)))

test_tinyxml_prod := \
	$(test_tinyxml_bins) \
	$(test_tinyxml_etcs) \
	$(test_tinyxml_includes) \
	$(test_tinyxml_libs) \
	$(test_tinyxml_shares)

# Dependency files:
test_tinyxml_deps := \
	$(addsuffix .d,$(basename $(test_tinyxml_src)))

test_tinyxml_cppflags := -DTIXML_USE_STL=YES -Itinyxml/include

##########################################################
# Add to our list of what the Makefile manages.
##########################################################

# Binaries etc. don't get added to these lists, sine unit tests don't
#   get installed.

SRC += $(test_tinyxml_src)
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
#   enough to deal with $(test_dir)/share/$(PKG_NAME)/test_tinyxml/*.xml
#   implicitly, but since hello.lo expects the xml file to be in
#   $(test_dir)/share/$(PKG_NAME)/foo and *not* in test_fo, we have to
#   deal with the xml file manually here.  (We also have to deal with
#   creating the directory manually.)

$(test_tinyxml_deps): CPPFLAGS += $(test_tinyxml_cppflags)
$(test_tinyxml_deps): test_tinyxml/module.mk

$(test_tinyxml_obj): CPPFLAGS += $(test_tinyxml_cppflags)

#$(test_dir)/bin/xmltest: LDFLAGS += -L$(stage_dir)/lib
$(test_dir)/bin/xmltest: \
	$(build_dir)/test_tinyxml/xmltest.lo \
	-ltinyxml-otm \
	| $(test_dir)/bin

##########################################################
# Phony targets:
##########################################################

test_tinyxml: $(test_tinyxml_prod)

clobber: clobber_test_tinyxml

.PHONY: clobber_test_tinyxml
clobber_test_tinyxml:
	$(LIBTOOL) --mode=clean $(RM) $(test_tinyxml_prod)

