// r10bbp4p: per-view PARAMETER typespec binding census — which typespec
// object (kind/name/span) and which vpiInstance each package/module parameter
// binds.  typespec::Compare recurses vpiInstance, so a parameter bound to the
// right-looking typespec carrying the WRONG package instance is a whole-design
// cmp failure the listing censuses cannot see.
// Build:
//   g++ -std=c++20 -O0 tools/probe/r10bbp4p.cpp -o /tmp/r10bbp4pq \
//       -I$HOME/.local/include $HOME/.local/lib64/libuhdm.a \
//       $HOME/.local/lib64/libcapnp.a $HOME/.local/lib64/libkj.a -lpthread
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <iostream>
#include <string>
using namespace UHDM;

static std::string tsDesc(const ref_typespec* r) {
    if (!r) return "noref";
    auto* a = r->Actual_typespec();
    if (!a) return "null";
    return std::string(UhdmName(a->UhdmType())) + " '" +
           std::string(a->VpiName()) + "' #" + std::to_string(a->UhdmId()) +
           " @" + std::to_string(a->VpiLineNo()) +
           ":" + std::to_string(a->VpiColumnNo()) + " inst=" +
           (a->Instance() ? std::string(a->Instance()->VpiName())
                          : std::string("-"));
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
