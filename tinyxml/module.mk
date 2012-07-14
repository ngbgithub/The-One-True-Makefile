##########################################################
# Define some useful variables.
##########################################################

tinyxml_src := \
	tinyxml/src/tinyxml.cpp	\
	tinyxml/src/tinyxmlparser.cpp	\
	tinyxml/src/tinyxmlerror.cpp	\
	tinyxml/src/tinystr.cpp

tinyxml_bins :=

tinyxml_etcs :=

tinyxml_includes := \
	$(stage_dir)/include/$(PKG_NAME)/tinyxml/tinyxml.h	\
	$(stage_dir)/include/$(PKG_NAME)/tinyxml/tinystr.h

tinyxml_libs := $(stage_dir)/lib/libtinyxml-otm.la

tinyxml_obj := \
	$(addprefix $(build_dir)/tinyxml/,\
		$(notdir $(tinyxml_src:.cpp=.lo)))

tinyxml_prod := \
	$(tinyxml_bins) \
	$(tinyxml_etcs) \
	$(tinyxml_includes) \
	$(tinyxml_libs) \
	$(tinyxml_shares)

# Dependency files:
tinyxml_deps := $(addsuffix .d,$(basename $(tinyxml_src)))

tinyxml_cppflags := -DTIXML_USE_STL=YES -Itinyxml/include

##########################################################
# Add to our list of what the Makefile manages.
##########################################################

SRC += $(tinyxml_src)
BIN_INSTALL_LIST += $(tinyxml_bins)
LIB_INSTALL_LIST += $(tinyxml_libs)
ETC_INSTALL_LIST += $(tinyxml_includes)
SHARE_INSTALL_LIST += $(tinyxml_shares)
INCLUDE_INSTALL_LIST += $(tinyxml_includes)

##########################################################
# Dependencies and rules:
##########################################################

$(tinyxml_deps): CPPFLAGS += $(tinyxml_cppflags)
$(tinyxml_deps): tinyxml/module.mk

$(tinyxml_obj): CPPFLAGS += $(tinyxml_cppflags)

$(stage_dir)/lib/libtinyxml-otm.la: $(tinyxml_obj) | $(stage_dir)/lib
	$(call link_lib_rule)

##########################################################
# Phony targets:
##########################################################

tinyxml: $(tinyxml_prod)

