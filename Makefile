# -----------------------------------------------------------------------------
# File:        Makefile
# Description: Genreic GCC based Makefile for compiling C/C++ programs
# -----------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Pull in the project makefile which expects the following to be set:
# EXECUTABLE  - final output file name
# BUILD_DIR   - directory you want to build in
# SRC_DIRS    - any source directories to compile wholesale
# CC_SOURCES  - any additional one-off C files
# INC_DIRS    - any additional directories to include
# LIB_DIRS    - list of library search paths
# LIBS        - list of libraries to include (e.g. usb, mylib, etc...)
# CFLAGS      - any flags to set for C compilation
# LDFLAGS     - any linker flags to set
# ------------------------------------------------------------------------------
include project.mk

# ------------------------------------------------------------------------------
# Gather up all the source files into SOURCES
# ------------------------------------------------------------------------------
SOURCES += $(foreach dir, $(SRC_DIRS), $(wildcard $(dir)/*.c))
SOURCES += $(foreach dir, $(SRC_DIRS), $(wildcard $(dir)/*.s))
SOURCES += $(ADDL_SOURCES)
SOURCES := $(abspath $(SOURCES))

# ------------------------------------------------------------------------------
# Create a list of INCLUDES
# ------------------------------------------------------------------------------
INC_DIRS := $(abspath $(INC_DIRS))
INC_DIRS += $(dir $(abspath $(SOURCES)))
INC_DIRS := $(strip $(sort $(INC_DIRS)))
CFLAGS += $(addprefix -I,$(INC_DIRS))

# ------------------------------------------------------------------------------
# Add the libraries to the linker flags
# ------------------------------------------------------------------------------
LDFLAGS += $(addprefix -L,$(LIB_DIRS))
LDLIBS  := $(addprefix -l,$(LIBS))

# ------------------------------------------------------------------------------
# Object Lists
# ------------------------------------------------------------------------------
OBJECTS  := $(SOURCES:.c=.o)
OBJS_DIR := $(BUILD_DIR)/$(TARGET)/obj
OBJECTS  := $(addprefix $(OBJS_DIR),$(OBJECTS))

# ------------------------------------------------------------------------------
# Build Tasks
# ------------------------------------------------------------------------------
all:
	@$(DOCKER_COMMAND_PREFIX) make fromdocker

#called from inside of docker build container to build the sdk and application
fromdocker: $(BUILD_DIR)/$(TARGET)/$(EXECUTABLE)
	@echo Done building: $(BUILD_DIR)/$(TARGET)/$(EXECUTABLE)


#link sdk and user code into binary executable 
$(BUILD_DIR)/$(TARGET)/$(EXECUTABLE): $(OBJECTS) $(BUILD_DIR)/$(TARGET)/startup_ch32v30x_D8C.o
	@echo Linking "  ($(CC))": $(abspath $@)
	@$(CC) -mabi=$(ABI) $(OPT) -march=$(ARCH) $(CFLAGS) -Wl,-Map,$(EXECUTABLE).map,$(LDFLAGS) --specs=nano.specs --specs=nosys.specs  -T  $(LINKER_DIRECTORY)/Link.ld $^ $(LDLIBS) -o $@


#assemble startup code for processor
$(BUILD_DIR)/$(TARGET)/startup_ch32v30x_D8C.o:$(SDK_LOCATION)/Startup/startup_ch32v30x_D8C.S
	@$(CC) $(OPT) -mabi=$(ABI) -march=$(ARCH) $(CFLAGS) -x assembler -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@)" -c -o $@  $<

#compile sdk & application into object files
$(OBJS_DIR)/%.o : $(dir $*)/%.c
	@echo Compiling "($(CC))": $< --\> $@
	@mkdir -p $(@D)
	@$(CC) -MMD -MP -mabi=$(ABI) -march=$(ARCH) $(CFLAGS) -c $< -o $@

# Auto-generated dependency files included as rules
-include $(OBJECTS:.o=.d)

clean:
	@echo Deleting contents of $(BUILD_DIR)/$(TARGET)
	@$(DOCKER_COMMAND_PREFIX) rm -rf $(BUILD_DIR)/$(TARGET)/* $(EXECUTABLE).map