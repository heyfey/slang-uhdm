// r10uvm192 — THE VIEW MAP.  MEASUREMENT ONLY; the official uhdm-cmp is the
// judge.  For every package in a database: which LIST it is on
// (design.AllPackages = the DEFINITION view, design.TopPackages = the
// ELABORATED view), its VpiTop stamp, and the two populations this pass's law
// is written over — how many entries of its own `Task_funcs` carry a
// class-QUALIFIED `C::m` name, and how many methods hang off its class_defns.
//
// This is the measurement that decides which view carries the `C::m` listing
// in THIS corpus row: § pkgVarInitCmViewClone111's golden table was written
// over the uvm-1.2 include tree and must NOT be carried over by memory.
//
// build: g++ -O2 -std=c++17 ct192view.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct192view
// usage: ct192view <db.uhdm> <tag>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <cstdio>
#include <set>
#include <string>

using namespace UHDM;

static const design* topDesign(Serializer& s) {
    for (auto& kv : s.AllObjects())
        if (kv.first && kv.first->UhdmType() == uhdmdesign)
            return (const design*)kv.first;
    return nullptr;
}

static void report(const char* tag, const char* list, const package* p) {
    unsigned tfn = 0, qual = 0, cls = 0, clsm = 0;
    if (p->Task_funcs()) {
        tfn = (unsigned)p->Task_funcs()->size();
        for (auto* tf : *p->Task_funcs())
            if (std::string(tf->VpiName()).find("::") != std::string::npos) ++qual;
    }
    if (p->Class_defns()) {
        cls = (unsigned)p->Class_defns()->size();
        for (auto* c : *p->Class_defns())
            if (c->Task_funcs()) clsm += (unsigned)c->Task_funcs()->size();
    }
    printf("PKG\t%s\t%s\t%s\t#%u\tVpiTop=%d\tTask_funcs=%u\tqualified=%u"
           "\tClass_defns=%u\tclass_methods=%u\n",
           tag, list, std::string(p->VpiName()).c_str(), p->UhdmId(),
           (int)p->VpiTop(), tfn, qual, cls, clsm);
}

int main(int argc, char** argv) {
    if (argc < 3) { fprintf(stderr, "usage: ct192view <db.uhdm> <tag>\n"); return 2; }
    Serializer s;
    if (s.Restore(std::string(argv[1])).empty()) { printf("RESTORE_FAIL\n"); return 3; }
    const design* d = topDesign(s);
    if (!d) { printf("NO_DESIGN\n"); return 3; }
    std::set<const package*> seen;
    if (d->AllPackages())
        for (auto* p : *d->AllPackages()) { report(argv[2], "AllPackages", p); seen.insert(p); }
    if (d->TopPackages())
        for (auto* p : *d->TopPackages()) { report(argv[2], "TopPackages", p); seen.insert(p); }
    for (auto& kv : s.AllObjects())
        if (kv.first && kv.first->UhdmType() == uhdmpackage &&
            !seen.count((const package*)kv.first))
            report(argv[2], "UNLISTED", (const package*)kv.first);
    return 0;
}
