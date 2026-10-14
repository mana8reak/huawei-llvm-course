CC := clang
CXX := clang++

# to compile the graphic app with the pass, it should be in adjacent directory
APP_SRC_DIR := ../llvm-course-graphic-app/src
BUILD_DIR := build
TARGET := $(BUILD_DIR)/app
PASS := libPass.so

CFLAGS := -O2
PLUGIN_FLAGS := -fpass-plugin=./libPass.so
LDLIBS := -lSDL2

APP_OBJ := $(BUILD_DIR)/app.o
SIM_OBJ := $(BUILD_DIR)/sim.o
START_OBJ := $(BUILD_DIR)/start.o
LOG_OBJ := $(BUILD_DIR)/log.o

.PHONY: all clean

all: pass app

pass: $(PASS)
app: $(TARGET)

$(TARGET): $(APP_OBJ) $(SIM_OBJ) $(START_OBJ) $(LOG_OBJ) | $(PASS)
	$(CXX) $(CFLAGS) $^ $(LDLIBS) -o $@

$(PASS): src/pass.cpp
	$(CXX) $< -fPIC -shared -I$$(llvm-config --includedir) -o $@

$(APP_OBJ): $(APP_SRC_DIR)/app.c $(PASS) | $(BUILD_DIR)
	$(CC) $(CFLAGS) $(PLUGIN_FLAGS) -c $< -o $@

$(SIM_OBJ): $(APP_SRC_DIR)/sim.c | $(BUILD_DIR)
	$(CC) $(CFLAGS) -c $< -o $@

$(START_OBJ): $(APP_SRC_DIR)/start.c | $(BUILD_DIR)
	$(CC) $(CFLAGS) -c $< -o $@

$(LOG_OBJ): src/log.cpp | $(BUILD_DIR)
	$(CXX) $(CFLAGS) -c $< -o $@

$(BUILD_DIR):
	mkdir -p $@

clean:
	rm -rf $(BUILD_DIR) $(PASS)
