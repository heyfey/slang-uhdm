// r10bbp5p: per-view PARAMETER typespec binding census (r10bbp4p + the
// DEF/TOP discriminator).  typespec::Compare recurses vpiInstance, and a
// package's DEF and ELAB copies share VpiName and VpiLineNo -- so a typespec
// bound to the WRONG COPY of the right-named package is invisible to a
// name-only census yet fails the whole design (uhdm-cmp reports it as a bare
// `ref_typespec < parameter(X) < package(Y)` with no LHS counterpart, because
// only one of the two copies lists a typespec for X).
// Build:
//   g++ -std=c++20 -O0 tools/probe/r10bbp5p.cpp -o /tmp/r10bbp5pq \
//       -I$HOME/.local/include $HOME/.local/lib64/libuhdm.a \
//       $HOME/.local/lib64/libcapnp.a $HOME/.local/lib64/libkj.a -lpthread
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <iostream>
#include <string>
using namespace UHDM;

static std::string instDesc(const typespec* a) {
    auto* i = a->Instance();
    if (!i) return "-";
    std::string out(i->VpiName());
    if (i->UhdmType() == uhdmpackage)
        out += ((const package*)i)->VpiTop() ? "[TOP]" : "[DEF]";
    return out;
}

static std::string tsDesc(const ref_typespec* r) {
    if (!r) return "noref";
    auto* a = r->Actual_typespec();
    if (!a) return "null";
    return std::string(UhdmName(a->UhdmType())) + " '" +
           std::string(a->VpiName()) + "' #" + std::to_string(a->UhdmId()) +
           " @" + std::to_string(a->VpiLineNo()) +
           ":" + std::to_string(a->VpiColumnNo()) + " inst=" + instDesc(a);
}

template <typename V>
static void doInst(const std::string& tag, V* v) {
    if (!v) return;
    for (auto* p : *v) {
        if (!p->Parameters()) continue;
        for (auto* pa : *p->Parameters()) {
            const ref_typespec* rt = nullptr;
            if (pa->UhdmType() == uhdmparameter)
                rt = ((const parameter*)pa)->Typespec();
            std::cout << tag << "/" << p->VpiName() << " " << pa->VpiName()
                      << " -> " << tsDesc(rt) << "\n";
        }
    }
}

int main(int argc, char** argv) {
    if (argc < 2) return 1;
    Serializer ser;
    auto restored = ser.Restore(std::string(argv[1]));
    if (restored.empty()) return 2;
    design* d = (design*)((uhdm_handle*)restored[0])->object;
    doInst("ALLPKG", d->AllPackages());
    doInst("TOPPKG", d->TopPackages());
    doInst("ALLMOD", d->AllModules());
    doInst("TOPMOD", d->TopModules());
    return 0;
}
