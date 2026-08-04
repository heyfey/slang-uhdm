// r10bbp14d: TOP-view cont_assign census — index, span, LHS, and for every
// ref_obj in the assign, whether its vpiActual object belongs to the TOP
// module's Nets/Variables or to the DEF (AllModules[0]) listing's.  Answers
// "does the elaborated body bind the elaborated net or the def one" per
// reference, which the r10bbp13f drill can only report as a deep failLhs.
// Build:
//   g++ -std=c++20 -O1 tools/probe/r10bbp14d.cpp -o /tmp/r10bbp14dq \
//       -I$HOME/.local/include $HOME/.local/lib64/libuhdm.a \
//       $HOME/.local/lib64/libcapnp.a $HOME/.local/lib64/libkj.a -lpthread
// Usage: r10bbp14dq <db.uhdm>
#include <uhdm/UhdmListener.h>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <set>
#include <string>
using namespace UHDM;

static std::set<const BaseClass*> topSet, defSet;

static const char* where(const BaseClass* o) {
    if (!o) return "null";
    if (topSet.count(o)) return "TOP";
    if (defSet.count(o)) return "DEF";
    return "other";
}

class RefWalk : public UhdmListener {
 public:
    void enterRef_obj(const ref_obj* const o) override {
        auto* a = o->Actual_group();
        std::cout << "    ref '" << std::string(o->VpiName()) << "' @"
                  << o->VpiLineNo() << ":" << o->VpiColumnNo() << " -> "
                  << (a ? UhdmName(a->UhdmType()) : "<null>") << " id"
                  << (a ? a->UhdmId() : 0) << " [" << where(a) << "]\n";
    }
};

int main(int argc, char** argv) {
    if (argc < 2) return 1;
    Serializer ser;
    auto h = ser.Restore(std::filesystem::path(argv[1]));
    if (h.empty()) return 2;
    const design* d = (const design*)((uhdm_handle*)h[0])->object;
    const module_inst* def = (*d->AllModules())[0];
    const module_inst* top = (*d->TopModules())[0];
    auto fill = [](std::set<const BaseClass*>& s, const module_inst* m) {
        if (m->Nets())
            for (auto* n : *m->Nets()) s.insert(n);
        if (m->Variables())
            for (auto* v : *m->Variables()) s.insert(v);
    };
    fill(topSet, top);
    fill(defSet, def);
    if (!top->Cont_assigns()) return 0;
    size_t i = 0;
    for (auto* ca : *top->Cont_assigns()) {
        std::cout << "CA[" << i++ << "] @" << ca->VpiLineNo() << ":"
                  << ca->VpiColumnNo() << "  lhs="
                  << (ca->Lhs() ? std::string(ca->Lhs()->VpiName()) : "<null>")
                  << " [" << where(ca->Lhs()) << "]\n";
        RefWalk w;
        if (ca->Rhs()) w.listenAny(ca->Rhs());
    }
    return 0;
}
