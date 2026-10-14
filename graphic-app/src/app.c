#include "sim.h"

#define X_SIZE (SIM_X_SIZE / 4)
#define Y_SIZE (SIM_Y_SIZE / 4)

#define WALL 1
#define SPACE 0
#define GRAY 0xFF808080

#define ENABLE_RANDOM_SPLASH 1
#define TICKS_PER_SPLASH 100

void drawCell(int x, int y, int argb) {
    for (int dy = 0; dy < 4; dy++) {
        for (int dx = 0; dx < 4; dx++) {
            simPutPixel(x * 4 + dx, y * 4 + dy, argb);
        }
    }
}

void createMap(int *map) {
    for (int y = 0; y < Y_SIZE; ++y) {
        for (int x = 0; x < X_SIZE; ++x) {
            if (x == 0 || x == X_SIZE - 1 || y == 0 || y == Y_SIZE - 1) {
                map[y * X_SIZE + x] = WALL;
            } else if (x == X_SIZE / 2) {
                if (y % 25 < 12) {
                    map[y * X_SIZE + x] = WALL;
                } else {
                    map[y * X_SIZE + x] = SPACE;
                }
            } else {
                map[y * X_SIZE + x] = SPACE;
            }
        }
    }
}

void calcWave(int *curr, int *next, int *map) {
    for (int y = 1; y < Y_SIZE - 1; ++y) {
        for (int x = 1; x < X_SIZE - 1; ++x) {
            int idx = y * X_SIZE + x;
            if (map[idx] == WALL) continue;

            int wave = (curr[idx - X_SIZE] +
                        curr[idx + X_SIZE] +
                        curr[idx - 1] +
                        curr[idx + 1]) / 2 - next[idx];
            wave -= wave >> 7;

            next[idx] = wave;
        }
    }
}

void drawField(int *curr, int *map) {
    for (int y = 0; y < Y_SIZE; y++) {
        for (int x = 0; x < X_SIZE; x++) {
            int idx = y * X_SIZE + x;
            if (map[idx] == WALL) {
                drawCell(x, y, GRAY);
                continue;
            }

            int wave = curr[idx];

            int r = (wave < 0) ? -wave : 0;
            int g = (wave > 0) ? wave >> 2 : 0;
            int b = (wave > 0) ? (wave * wave) >> 5 : 0;

            if (r > 255) r = 255;
            if (g > 255) g = 255;
            if (b > 255) b = 255;

            drawCell(x, y, 0xFF000000 | (r << 16) | (g << 8) | b);
        }
    }
}

void addSplash(int *curr, int *map, int xy) {
    int cx = (xy >> 16) / 4;
    int cy = (xy & 0xFFFF) / 4;

    for (int dy = -1; dy <= 1; dy++) {
        for (int dx = -1; dx <= 1; dx++) {
            int nx = cx + dx;
            int ny = cy + dy;
            if (nx > 0 && nx < X_SIZE - 1 && ny > 0 && ny < Y_SIZE - 1 && map[ny * X_SIZE + nx] != WALL) {
                curr[ny * X_SIZE + nx] = 1500;
            }
        }
    }
}

void app(void) {
    int map[Y_SIZE * X_SIZE] = {};
    int field1[Y_SIZE * X_SIZE] = {};
    int field2[Y_SIZE * X_SIZE] = {};

    createMap(map);

    int *curr = field1;
    int *next = field2;

    while (1) {
        drawField(curr, map);
        simFlush();

        calcWave(curr, next, map);

        int *tmp = curr;
        curr = next;
        next = tmp;

        while (simHasClick()) {
            addSplash(curr, map, simGetClick());
        }
        if (ENABLE_RANDOM_SPLASH && simRand() % TICKS_PER_SPLASH == 0) {
            addSplash(curr, map, simRand() % SIM_X_SIZE << 16 | simRand() % SIM_Y_SIZE);
        }
    }
}
