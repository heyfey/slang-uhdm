// r10earl4t: POINTER-IDENTITY probe for § pkgTypespecInstanceIsTop.
// The dumps are TEXT-IDENTICAL when two package copies differ only by which
// object a vpiInstance points at, so print uid/top for every package copy and
// for every typespec that names one, on both sides.
// Usage: r10earl4t <a.uhdm> [b.uhdm]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <string>
using namespace UHDM;

static std::string uid(const BaseClass* b) {
    if (!b) return "<null>";
    return std::string(UhdmName(b->UhdmType())) + "#" + std::to_string(b->UhdmId());
}

static void showPkg(const char* tag, const package* p) {
    std::cout << "  " << tag << " " << uid(p) << " name=" << p->VpiName()
              << " top=" << (int)p->VpiTop() << "\n";
    if (p->Typespecs())
        for (auto* t : *p->Typespecs()) {
            std::cout << "      ts " << uid(t) << " '" << t->VpiName() << "' inst="
                      << uid(t->Instance()) << "\n";
        }
}

static void walkInst(const instance* m) {
    std::cout << "  MOD " << uid(m) << " def=" << m->VpiDefName()
              << " top=" << (int)m->VpiTop() << "\n";
    if (m->Parameters())
        for (auto* pr : *m->Parameters()) {
            const ref_typespec* rt = nullptr;
            if (pr->UhdmType() == uhdmparameter) rt = ((parameter*)pr)->Typespec();
            std::cout << "      param '" << pr->VpiName() << "' rt=" << uid(rt);
            const typespec* act = rt ? rt->Actual_typespec() : nullptr;
            std::cout << " actual=" << uid(act);
            if (act) std::cout << " actual.inst=" << uid(act->Instance());
            std::cout << "\n";
        }
    if (m->Param_assigns())
        for (auto* pa : *m->Param_assigns()) {
            const any* r = pa->Rhs();
            std::cout << "      pa rhs=" << uid(r);
            if (r && r->UhdmType() == uhdmconstant) {
                auto* c = (const constant*)r;
                const ref_typespec* rt = c->Typespec();
                std::cout << " ct=" << c->VpiConstType() << " rt=" << uid(rt);
                if (rt && rt->Actual_typespec())
                    std::cout << " actual=" << uid(rt->Actual_typespec())
                              << " actual.inst=" << uid(rt->Actual_typespec()->Instance());
            }
            std::cout << "\n";
        }
}

static void one(const char* label, const char* path) {
    Serializer s;
    auto h = s.Restore(std::filesystem::path(path));
    if (h.empty()) { std::cout << label << ": restore failed\n"; return; }
    const design* d = (const design*)((uhdm_handle*)h[0])->object;
    std::cout << "==== " << label << " " << path << "\n";
    if (d->AllPackages())
        for (auto* p : *d->AllPackages()) showPkg("ALLPKG", p);
    if (d->TopPackages())
        for (auto* p : *d->TopPackages()) showPkg("TOPPKG", p);
    if (d->AllModules())
        for (auto* m : *d->AllModules()) walkInst(m);
    if (d->TopModules())
        for (auto* m : *d->TopModules()) walkInst(m);
}

int main(int argc, char** argv) {
    for (int i = 1; i < argc; i++) one(i == 1 ? "A" : "B", argv[i]);
    return 0;
}
