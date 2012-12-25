##########################################################
# Define some useful variables.
##########################################################

tinyxml2_src := tinyxml2/src/tinyxml2.cpp

tinyxml2_bins :=

tinyxml2_etcs :=

tinyxml2_includes := $(stage_dir)/include/$(PKG_NAME)/tinyxml2/tinyxml2.h

tinyxml2_libs := $(stage_dir)/lib/libtinyxml2-otm.la

tinyxml2_obj := \
	$(addprefix $(build_dir)/tinyxml2/,\
		$(notdir $(tinyxml2_src:.cpp=.lo)))

tinyxml2_prod := \
	$(tinyxml2_bins) \
	$(tinyxml2_etcs) \
	$(tinyxml2_includes) \
	$(tinyxml2_libs) \
	$(tinyxml2_shares)

# Dependency files:
tinyxml2_deps := $(addsuffix .d,$(basename $(tinyxml2_src)))

tinyxml2_cppflags := -Itinyxml2/include

##########################################################
# Add to our list of what the Makefile manages.
##########################################################

SRC += $(tinyxml2_src)
BIN_INSTALL_LIST += $(tinyxml2_bins)
LIB_INSTALL_LIST += $(tinyxml2_libs)
ETC_INSTALL_LIST += $(tinyxml2_includes)
SHARE_INSTALL_LIST += $(tinyxml2_shares)
INCLUDE_INSTALL_LIST += $(tinyxml2_includes)

##########################################################
# Dependencies and rules:
##########################################################

$(tinyxml2_deps): CPPFLAGS += $(tinyxml2_cppflags)
$(tinyxml2_deps): tinyxml2/module.mk

$(tinyxml2_obj): CPPFLAGS += $(tinyxml2_cppflags)

$(stage_dir)/lib/libtinyxml2-otm.la: $(tinyxml2_obj) | $(stage_dir)/lib
	$(call link_lib_rule)

##########################################################
# Phony targets:
##########################################################

tinyxml2: $(tinyxml2_prod)

