### Start Preamble
SHELL := bash
.ONESHELL:
.SHELLFLAGS := -eu -o pipefail -c
.DELETE_ON_ERROR:
MAKEFLAGS += --warn-undefined-variables
### End Preamble

BUILD_DIR := build
SRC_DIR := src

TARGET := CCE
EXECUTABLE := $(BUILD_DIR)/$(TARGET)

SOURCES := $(wildcard $(SRC_DIR)/*.c)
OBJECTS := $(SOURCES:$(SRC_DIR)/%.c=$(BUILD_DIR)/%.o)

INC_DIRS := $(shell find $(SRC_DIR) -type d)
INC_FLAGS := $(addprefix -I,$(INC_DIRS))

CC := gcc
CFLAGS := -g -Wall -Wextra -Werror -O2 -std=c99 -pedantic
CPPFLAGS := $(INC_FLAGS) -MMD -MP
LDFLAGS := -Llib
LDLIBS := -lm

.PHONY: default all run clean test format

default: $(EXECUTABLE)
all: default

$(EXECUTABLE): $(OBJECTS) | $(BUILD_DIR)
	$(CC) $(LDFLAGS) $^ $(LDLIBS) -o $@

$(BUILD_DIR)/%.o: $(SRC_DIR)/%.c | $(BUILD_DIR)
	$(CC) $(CPPFLAGS) $(CFLAGS) -c $< -o $@

$(BUILD_DIR):
	mkdir -p $@

run: $(EXECUTABLE)
	@./$(EXECUTABLE)

clean:
	@$(RM) -rv $(BUILD_DIR)

test: $(EXECUTABLE)
	pre-commit run --all-files

format: $(SOURCES)
	clang-format --style=Google -i $(SOURCES)

-include $(OBJECTS:.o=.d)
