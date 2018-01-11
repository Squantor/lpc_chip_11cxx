# Project settings
BIN_NAME = liblpc_chip_11cxx
SOURCES = src/adc_11xx.c src/adc_1125.c src/chip_11xx.c src/clock_11xx.c src/gpio_11xx_1.c src/gpio_11xx_2.c \
src/gpiogroup_11xx.c src/i2c_11xx.c src/iocon_11xx.c src/pinint_11xx.c src/pmu_11xx.c src/ring_buffer.c \
src/ssp_11xx.c src/sysctl_11xx.c src/sysinit_11xx.c src/timer_11xx.c src/uart_11xx.c src/wwdt_11xx.c
INCLUDES = -Iinc -I"../squantlibraries/sqlibc/inc"

# Toolchain settings
MAKE = make
MKDIR = mkdir
RM = rm
CXX = gcc
CXX_PREFIX = arm-none-eabi-
SIZE = size
AR = ar
OBJDUMP = objdump

# Toolchain flags
COMPILE_FLAGS = -Wall -c -fmessage-length=0 -fno-builtin -ffunction-sections -fdata-sections -std=c11 -mcpu=cortex-m0 -mthumb
DEFINES = -DCORE_M0
RDEFINES = -DNDEBUG
DDEFINES = -DDEBUG
RCOMPILE_FLAGS = $(DEFINES) $(RDEFINES) -Os
DCOMPILE_FLAGS = $(DEFINES) $(DDEFINES) -g3 -O0

LINK_FLAGS =
RLINK_FLAGS =
DLINK_FLAGS =

# other settings
SRC_EXT = c

# Clear built-in rules
.SUFFIXES:

# Function used to check variables. Use on the command line:
# make print-VARNAME
# Useful for debugging and adding features
print-%: ; @echo $*=$($*)

# Combine compiler and linker flags
release: export CXXFLAGS := $(CXXFLAGS) $(COMPILE_FLAGS) $(RCOMPILE_FLAGS)
release: export LDFLAGS := $(LINK_FLAGS) $(RLINK_FLAGS)
debug: export CXXFLAGS := $(CXXFLAGS) $(COMPILE_FLAGS) $(DCOMPILE_FLAGS)
debug: export LDFLAGS := $(LINK_FLAGS) $(DLINK_FLAGS)

# Build and output paths
release: export BUILD_PATH := build/release
release: export BIN_PATH := bin/release
debug: export BUILD_PATH := build/debug
debug: export BIN_PATH := bin/debug

# Set the object file names, with the source directory stripped
# from the path, and the build path prepended in its place
OBJECTS = $(SOURCES:%.$(SRC_EXT)=$(BUILD_PATH)/%.o)
# Set the dependency files that will be used to add header dependencies
DEPS = $(OBJECTS:.o=.d)

# Standard, non-optimized release build
.PHONY: release
release: dirs
	$(MAKE) all --no-print-directory

# Debug build for gdb debugging
.PHONY: debug
debug: dirs
	$(MAKE) all --no-print-directory

# Create the directories used in the build
.PHONY: dirs
dirs:
	$(MKDIR) -p $(BUILD_PATH)
	$(MKDIR) -p $(BIN_PATH)

# Removes all build files
.PHONY: clean clean_debug clean_release
clean_debug:
clean_release:
clean:
	$(RM) -r build
	$(RM) -r bin

# Main rule, checks the executable and symlinks to the output
all: $(BIN_PATH)/$(BIN_NAME).a

# create the archive
$(BIN_PATH)/$(BIN_NAME).a: $(OBJECTS)
	$(CXX_PREFIX)$(AR) -r $@ $(OBJECTS)
	$(CXX_PREFIX)$(SIZE) $@
	$(CXX_PREFIX)$(OBJDUMP) -h -S "$@" > "$(BIN_PATH)/$(BIN_NAME).lss"

# Add dependency files, if they exist
-include $(DEPS)

# Source file rules
# After the first compilation they will be joined with the rules from the
# dependency files to provide header dependencies
# if the source file is in a subdir, create this subdir in the build dir
$(BUILD_PATH)/%.o: ./%.$(SRC_EXT)
	$(MKDIR) -p $(dir $@) 
	$(CXX_PREFIX)$(CXX) $(CXXFLAGS) $(INCLUDES) -MP -MMD -c $< -o $@
