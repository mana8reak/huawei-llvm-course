#include <algorithm>
#include <array>
#include <cstdint>
#include <cstdio>
#include <cstring>
#include <functional>
#include <limits>
#include <signal.h>
#include <unordered_map>
#include <vector>
#include <unistd.h>

namespace {
    template<std::size_t N>
    struct ArrayHash {
        std::size_t operator()(const std::array<uint16_t, N> &ops) const noexcept {
            std::size_t h = 0;
            for (uint16_t op : ops) {
                h ^= std::hash<uint16_t>{}(op) + 0x9e3779b9 + (h << 6) + (h >> 2);
            }
            return h;
        }
    };

    template<std::size_t N>
    using CountInstrSeq = std::unordered_map<
        std::array<uint16_t, N>,
        uint64_t,
        ArrayHash<N>
    >;

    CountInstrSeq<1> count1;
    CountInstrSeq<2> count2;
    CountInstrSeq<3> count3;
    CountInstrSeq<4> count4;
    CountInstrSeq<5> count5;

    uint64_t c_total = 0;
    constexpr std::size_t max_window_len = 5;
    constexpr uint16_t instr_n = std::numeric_limits<uint16_t>::max();
    uint16_t window[max_window_len];
    std::size_t curr_window_len = 0;
    const char *instr_names[instr_n];
    bool dumped = false;

    template<std::size_t N>
    void incCounter(CountInstrSeq<N> &map) {
        std::array<uint16_t, N> key{};

        for (std::size_t i = 0; i < N; ++i) {
            key[i] = window[i];
        }

        ++map[key];
    }

    template<std::size_t N>
    void writeCount(FILE *f, const CountInstrSeq<N> &map) {
        const uint32_t size = static_cast<uint32_t>(map.size());

        fwrite(&size, sizeof(size), 1, f);

        for (const auto &[ops, cnt]: map) {
            fwrite(ops.data(), sizeof(uint16_t), N, f);
            fwrite(&cnt, sizeof(cnt), 1, f);
        }
    }

    void dumpTrace() {
        if (dumped) {
            return;
        }
        FILE *f = fopen("llvm_trace_aggregated.bin", "wb");
        if (!f) {
            fprintf(stderr, "[Profiler] Failed to open output file\n");
            return;
        }
        dumped = true;

        fwrite(&c_total, sizeof(c_total), 1, f);
        writeCount(f, count1);
        writeCount(f, count2);
        writeCount(f, count3);
        writeCount(f, count4);
        writeCount(f, count5);

        uint32_t n_names = 0;
        for (const char *name: instr_names) {
            if (name) {
                ++n_names;
            }
        }
        fwrite(&n_names, sizeof(n_names), 1, f);

        for (uint32_t i = 0; i < instr_n; ++i) {
            const char *name = instr_names[i];

            if (!name) {
                continue;
            }

            const uint16_t id = static_cast<uint16_t>(i);
            const uint8_t len = static_cast<uint8_t>(std::strlen(name));

            fwrite(&id, sizeof(id), 1, f);
            fwrite(&len, sizeof(len), 1, f);
            fwrite(name, 1, len, f);
        }
        fclose(f);
        fprintf(stderr, "[Tracer] %llu events aggregated -> llvm_trace_aggregated.bin\n", static_cast<unsigned long long>(c_total));
    }

    void handleSignal(int sig) {
        dumpTrace();
        _exit(0);
    }

    __attribute__((constructor))
    void initTracer() {
        struct sigaction sa{};

        sa.sa_handler = handleSignal;
        sigemptyset(&sa.sa_mask);
        sa.sa_flags = 0;

        sigaction(SIGABRT, &sa, nullptr);
    }

} // namespace

extern "C" void registerOpcodeName(uint16_t id, const char *name) {
    instr_names[id] = name;
}

extern "C" void logUserOperand(uint16_t user_op, uint16_t operand_op) {
    ++c_total;

    if (curr_window_len > 0 && window[0] == operand_op) {
        const int last = std::min(curr_window_len, max_window_len - 1);
        for (int i = last; i >= 2; --i) {
            window[i] = window[i - 1];
        }
        if (curr_window_len < max_window_len) {
            ++curr_window_len;
        }
    } else {
        curr_window_len = 2;
    }

    window[0] = user_op;
    window[1] = operand_op;

    if (curr_window_len >= 1) {
        incCounter(count1);
    }
    if (curr_window_len >= 2) {
        incCounter(count2);
    }
    if (curr_window_len >= 3) {
        incCounter(count3);
    }
    if (curr_window_len >= 4) {
        incCounter(count4);
    }
    if (curr_window_len >= 5) {
        incCounter(count5);
    }
}
