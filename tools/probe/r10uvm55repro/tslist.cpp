// r10uvm55repro/tslist.cpp — LIST the Typespecs() vector of every container
// that has one (design, package, module_inst, class_defn, and any scope), in
// UHDM POSITIONAL ORDER, with each element's kind / name / span.
//
// WHY a C++ probe and not a dump grep: uhdm-dump's indentation is NOT a faithful
// depth (it abbreviates already-printed objects and re-prints back-references),
// so "which vector does this class_typespec sit in" cannot be read off a dump.
// `class_typespec::Compare` and `SafeCompare(lhs->Typespecs(), ...)` compare
// these vectors POSITIONALLY, so the position is the thing that matters.
//
// LHS is ALWAYS golden(Surelog); RHS is ALWAYS ours.
//
//   usage: tslist <db.uhdm> [nameFilter]
//     prints  <containerKind>|<containerName>|<idx>|<elemKind>|<elemName>|<file>:<l>:<c>-<el>:<ec>|parent=<kind>:<name>
//
// GUARDS:
//   * a database that yields NO design is `UNMEASURED: no design` and exit 4 —
//     an empty listing must never read as "the vector is empty".
//   * a container whose Typespecs() is null prints `<null-vector>` explicitly,
//     distinct from a container whose Typespecs() is an EMPTY vector.
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <iostream>
#include <set>
#include <string>
#include <vector>
using namespace UHDM;

static std::string nm(const BaseClass* o) {
    if (!o) return "<null>";
    std::string s(o->VpiName());
    
    if (s.empty()) s = "<anon>";
    return s;
}
static std::string kindOf(const BaseClass* o) {
    return o ? std::string(UhdmName(o->UhdmType())) : std::string("<null>");
}
static std::string span(const BaseClass* o) {
    if (!o) return "-";
    return std::string(o->VpiFile()) + ":" + std::to_string(o->VpiLineNo()) +
           ":" + std::to_string(o->VpiColumnNo()) + "-" +
           std::to_string(o->VpiEndLineNo()) + ":" +
           std::to_string(o->VpiEndColumnNo());
}

static std::string g_filter;
static void emit(const BaseClass* cont, const VectorOftypespec* v) {
    std::string ck = kindOf(cont), cn = nm(cont);
    if (!v) {
        if (g_filter.empty())
            std::cout << ck << "|" << cn << "|-|<null-vector>|-|-|-\n";
        return;
    }
    for (size_t i = 0; i < v->size(); i++) {
        const typespec* t = (*v)[i];
        std::string en = nm(t);
        if (!g_filter.empty() && en.find(g_filter) == std::string::npos)
            continue;
        std::cout << ck << "|" << cn << "|" << i << "|" << kindOf(t) << "|" << en
                  << "|" << span(t) << "|parent=" << kindOf(t ? t->VpiParent() : nullptr)
                  << ":" << nm(t ? t->VpiParent() : nullptr) << "\n";
    }
}

int main(int argc, char** argv) {
    if (argc < 2) { std::cerr << "usage: tslist <db.uhdm> [nameFilter]\n"; return 2; }
    if (argc > 2) g_filter = argv[2];
    Serializer s;
    const std::vector<vpiHandle> restored = s.Restore(std::string(argv[1]));
    if (restored.empty()) { std::cout << "UNMEASURED: no design in " << argv[1] << "\n"; return 4; }
    const design* d = (const design*)((const uhdm_handle*)restored[0])->object;
    if (!d) { std::cout << "UNMEASURED: no design object\n"; return 4; }
    emit(d, d->Typespecs());
    if (d->AllPackages())
        for (auto* p : *d->AllPackages()) emit(p, p->Typespecs());
    if (d->TopPackages())
        for (auto* p : *d->TopPackages()) emit(p, p->Typespecs());
    if (d->AllClasses())
        for (auto* c : *d->AllClasses()) emit(c, c->Typespecs());
    if (d->AllModules())
        for (auto* m : *d->AllModules()) emit(m, m->Typespecs());
    if (d->TopModules())
        for (auto* m : *d->TopModules()) emit(m, m->Typespecs());
    return 0;
}
