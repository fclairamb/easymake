# This is makefile skeleton that can be pretty much used as-is.
# I'm sure we can simplify it a bit.

# You can run your binary by typing
# make test
# make test CONF=Size

# Limitations:
# * You need to do a clean when adding a directory in src

# Name
NAME=mybin

# Flags we will add to the one we pass
CFLAGS+=-Wall -Werror -fPIC

# Target dir to put the binary in
TARGET_DIR=/bin

# For a shared library you would need to add:
# LDFLAGS=-shared
# TARGET_DIR=/lib
# NAME:=$(NAME).so

# Libraries we will use
LDLIBSOPTIONS=\
-ldl \
-lz \
-ljson-c \
-lssl \
-lcrypto \
-lpthread

# Arch flags:
# ARCHFLAGS=-m32

CXXFLAGS=$(CFLAGS)

# Prefix (for install)
ifeq "$(PREFIX)" ""
	PREFIX:=usr
endif

# Destdir (for install)
ifeq "$(DESTDIR)" ""
	DESTDIR:=/
endif

# Configuration: Debug / Release
ifeq "$(CONF)" ""
	CONF=Debug
endif
ifeq "$(CONF)" "Debug"
    CFLAGS+=-O0 -g -fPIC
endif
ifeq "$(CONF)" "Size"
	CFLAGS+=-Os
endif
ifeq "$(CONF)" "Release"
    CFLAGS+=-O2 -fPIC
    DEFINES+=-DNDEBUG
endif

# Compilation tools
CC:=$(CROSS_COMPILE)gcc
CXX:=$(CROSS_COMPILE)g++
AR:=$(CROSS_COMPILE)ar

# Building directory
BUILD:=build/$(CROSS_COMPILE)$(CONF)

# Final distribuable binaries
DIST:=dist/$(CROSS_COMPILE)$(CONF)
TARGET:=$(DIST)/$(NAME)

# You should probably keep this include as is
INCLUDES:=-Isrc

# Dirty build things
SRCS_CPP:=$(shell find src -name "*.cpp")
SRCS_C:=$(shell find src -name "*.c")
OBJ:=\
$(addprefix $(BUILD)/,$(patsubst %.cpp,%.cpp_o,$(wildcard $(SRCS_CPP)))) \
$(addprefix $(BUILD)/,$(patsubst %.c,%.c_o,$(wildcard $(SRCS_C))))
MAKEFILE_INCLUDE:=\
$(addprefix $(BUILD)/,$(patsubst %.cpp,%.cpp_o.d,$(wildcard $(SRCS_CPP)))) \
$(addprefix $(BUILD)/,$(patsubst %.c,%.c_o.d,$(wildcard $(SRCS_C))))

ifneq "$(ARCHFLAGS)" ""
    CFLAGS:=$(CFLAGS) $(ARCHFLAGS)
    CXXFLAGS:=$(CXXFLAGS) $(ARCHFLAGS)
    LDFLAGS:=$(LDFLAGS) $(ARCHFLAGS)
endif

all: build
	
modules: $(MODULES)

build: $(TARGET)
	@[ ! -e dist/last ] || rm dist/last
	@ln -s $(CROSS)$(CONF) dist/last

# Final binary
$(TARGET): $(OBJ) $(DIST)
	$(CXX) -o $(TARGET) $(OBJ) $(LDLIBSOPTIONS) $(LDFLAGS)

# For a shared library
# $(CXX) -shared -o $(TARGET) $(CXXFLAGS) $(OBJ) $(LDLIBSOPTIONS)

$(BUILD)/%.cpp_o: %.cpp $(BUILD)
	$(CXX) -c -o $@ $< $(CXXFLAGS) $(INCLUDES) $(DEFINES) 
	$(CXX) -MM -o $@.d -MT $@ $< $(CXXFLAGS) $(INCLUDES) $(DEFINES) 

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

# Test this with: make install DESTDIR=./install PREFIX=/
install: $(TARGET)
	# For binaries
	[ -d $(DESTDIR)$(PREFIX)$(TARGET_DIR) ] || mkdir -p $(DESTDIR)$(PREFIX)$(TARGET_DIR)
	cp $(TARGET) $(DESTDIR)$(PREFIX)$(TARGET_DIR)/$(NAME)

test: $(TARGET)
	@printf "\n\n==================== Running $(TARGET) ====================\n\n"
	@$(TARGET)

clean:
	rm -Rf build dist
