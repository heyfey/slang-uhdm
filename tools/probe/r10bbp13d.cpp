// r10bbp13d: per-VIEW census of every parameter's CMP-relevant scalar fields
// (vpiConstType / vpiSigned / vpiLocalParam / vpiName / vpiImported -- exactly
// what parameter::Compare reads on the object itself) plus its declaration
// span.  Walks the design's own vectors only, so each listing is visited once
// and a plain `diff` of golden-vs-ours output is the honest census.
// Written for the BlackBePipeInt pass-13 R1 head: 182 same-name parameter
// pairs that differ only in vpiImported (home package vs re-exporter).
// Build:
//   g++ -std=c++20 -O1 tools/probe/r10bbp13d.cpp -o /tmp/r10bbp13dq \
//       -I$HOME/.local/include $HOME/.local/lib64/libuhdm.a \
//       $HOME/.local/lib64/libcapnp.a $HOME/.local/lib64/libkj.a -lpthread
// Usage: r10bbp13dq <db.uhdm> [name-filter]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <string>
using namespace UHDM;

static std::string want;

static void dumpP(const std::string& view, const parameter* p) {
    if (!want.empty() && std::string(p->VpiName()) != want) return;
    std::cout << view << "  " << p->VpiName()
              << (want.empty() ? "" : " #" + std::to_string(p->UhdmId()))
              << " @" << p->VpiLineNo() << ":"
              << p->VpiColumnNo() << " ct=" << p->VpiConstType()
              << " signed=" << p->VpiSigned() << " local=" << p->VpiLocalParam()
              << " imported='" << p->VpiImported() << "'";
    // The typespec chain typespec::Compare walks: actual kind + its
    // vpiInstance (the § pass-13 R1b residue).
    if (auto* rt = p->Typespec()) {
        auto* a = rt->Actual_typespec();
        std::cout << " ts=" << (a ? UhdmName(a->UhdmType()) : "null");
        if (a)
            std::cout << "@" << a->VpiLineNo() << ":" << a->VpiColumnNo()
                      << " tsInst="
                      << (a->Instance() ? std::string(a->Instance()->VpiName())
                                        : std::string("<null>"));
    }
    else
        std::cout << " ts=<norf>";
    std::cout << "\n";
}

int main(int argc, char** argv) {
    if (argc < 2) return 1;
    if (argc > 2) want = argv[2];
    Serializer ser;
    auto h = ser.Restore(std::filesystem::path(argv[1]));
    if (h.empty()) return 2;
    const design* d = (const design*)((uhdm_handle*)h[0])->object;
    auto doVec = [&](const char* tag, auto* v) {
        if (!v) return;
        int i = 0;
        for (auto* e : *v) {
            std::string view =
                std::string(tag) + "[" + std::to_string(i) + "]" +
                std::string(e->VpiName());
            if (auto* ps = ((const scope*)e)->Parameters())
                for (auto* pp : *ps)
                    if (pp->UhdmType() == uhdmparameter)
                        dumpP(view + " P", (const parameter*)pp);
            // The param_assign's Lhs is NOT always the same object as the
            // Parameters-vector entry -- the module import copy keeps its own.
            if (auto* pas = ((const scope*)e)->Param_assigns())
                for (auto* pa : *pas)
                    if (pa->Lhs() && pa->Lhs()->UhdmType() == uhdmparameter)
                        dumpP(view + " A", (const parameter*)pa->Lhs());
            i++;
        }
    };
    doVec("AllPkg", d->AllPackages());
    doVec("TopPkg", d->TopPackages());
    doVec("AllMod", d->AllModules());
    doVec("TopMod", d->TopModules());
    return 0;
}
