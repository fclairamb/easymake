# This is makefile skeleton can be used as-is for many projects.

# You can run your binary by typing
# make run

# Limitations:
# * You need to do a clean when adding a directory in src

# Name
NAME=mybin

# Flags we will add to the one we pass
CFLAGS+=-Wall -Werror -Wextra -rdynamic -fPIC

# Target dir to put the binary in
TARGET_DIR=/bin

# For a shared library you would need to add:
# LDFLAGS=-shared
# TARGET_DIR=/usr/lib
# NAME:=$(NAME).so

# include is only useful if you're making a library and want to share include files
INCLUDES:=-Isrc -Iinclude

# Libraries we will use
LDLIBSOPTIONS=\
-ldl \
-lz \
-lssl \
-lcrypto \
-lpthread

CXXFLAGS=$(CFLAGS)

# Configuration: Debug / Release
ifeq "$(CONF)" ""
	CONF=Debug
endif
ifeq "$(CONF)" "Debug"
    CFLAGS+=-O0 -g -fPIC
endif
ifeq "$(CONF)" "Release"
    CFLAGS+=-O2 -fPIC
    DEFINES+=-DNDEBUG
endif

ifndef PREFIX
	PREFIX=/usr
endif

# Compilation tools
CC:=$(CROSS_COMPILE)gcc
CXX:=$(CROSS_COMPILE)g++
AR:=$(CROSS_COMPILE)ar

# Building directory
BUILD:=build/$(CROSS_COMPILE)$(CONF)

# Final distribuable binaries
DIST:=dist/$(CROSS_COMPILE)$(CONF)
OUTPUT:=$(DIST)/$(NAME)

# We search for all the C and C++ files
SRCS_CPP:=$(shell find src -name "*.cpp")
SRCS_C:=$(shell find src -name "*.c")

# We defile some auto-generated object files
OBJ:=\
$(addprefix $(BUILD)/,$(patsubst %.cpp,%.cpp_o,$(wildcard $(SRCS_CPP)))) \
$(addprefix $(BUILD)/,$(patsubst %.c,%.c_o,$(wildcard $(SRCS_C))))

# We define some auto-generated definition files
MAKEFILE_INCLUDE:=\
$(addprefix $(BUILD)/,$(patsubst %.cpp,%.cpp_o.d,$(wildcard $(SRCS_CPP)))) \
$(addprefix $(BUILD)/,$(patsubst %.c,%.c_o.d,$(wildcard $(SRCS_C))))

# We add the INCLUDES flags
CFLAGS += $(INCLUDES)

# This might not make that much sence
ifneq "$(ARCHFLAGS)" ""
    CFLAGS += $(ARCHFLAGS)
    LDFLAGS += $(ARCHFLAGS)
endif


$(NAME): $(OUTPUT)
	ln -f $(OUTPUT) $(NAME)

# Final binary
$(OUTPUT): $(OBJ) $(DIST)
	$(CXX) -o $(OUTPUT) $(OBJ) $(LDLIBSOPTIONS) $(LDFLAGS)

# C++ compilation and dependencies generation
$(BUILD)/%.cpp_o: %.cpp $(BUILD)
	$(CXX) -c -o $@ $< $(CXXFLAGS) $(INCLUDES) $(DEFINES)
	$(CXX) -MM -o $@.d -MT $@ $< $(CXXFLAGS) $(INCLUDES) $(DEFINES)

# C compilation and dependencies generation
$(BUILD)/%.c_o: %.c $(BUILD)
	$(CC) -c -o $@ $< $(CFLAGS) $(INCLUDES) $(DEFINES)
	$(CC) -MM -o $@.d -MT $@ $< $(CFLAGS) $(INCLUDES) $(DEFINES)

-include $(MAKEFILE_INCLUDE)

build: $(BUILD)

# We create the same directories we have in "src" in "build" 
$(BUILD):
	find src -type d -exec mkdir -p $(BUILD)/{} \;
	touch $(BUILD)

$(DIST):
	mkdir -p $(DIST)

all-releases:
	@make CONF=Release
	@make CONF=Debug

doc:
	[ ! -f Doxyfile ] || doxygen

all: all-releases doc


# Test this with: make install DESTDIR=./install
install: $(OUTPUT)
	# For binaries
	mkdir -p $(DESTDIR)$(PREFIX)$(TARGET_DIR)
	cp $(OUTPUT) $(DESTDIR)$(PREFIX)$(TARGET_DIR)/$(NAME)

run: $(OUTPUT)
	@printf "\n\n==================== Running $(TARGET) ====================\n\n"
	@$(OUTPUT)

clean:
	rm -Rf build dist $(NAME)
