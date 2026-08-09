// r10uvm27cv — CLASS-PROPERTY field census: for every class_defn reachable
// from AllPackages/TopPackages/AllClasses, print each Variables entry's
// cmp-relevant scalar fields (kind, vpiConstantVariable, vpiAutomatic,
// vpiVisibility, typespec kind, expr kind).  The projection behind
// § constClassPropIsConstantVariable27.
//   r10uvm27cv <file.uhdm> [nameFilter]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <set>
#include <string>
using namespace UHDM;

static std::string tn(const BaseClass* o) {
    return std::string(UhdmName(o->UhdmType()));
}
static std::string filt;
static std::set<const class_defn*> seen;

static void doClass(const char* tag, const class_defn* c) {
    if (!c || !seen.insert(c).second) return;
    std::string nm(c->VpiFullName().empty() ? c->VpiName() : c->VpiFullName());
    if (!filt.empty() && nm.find(filt) == std::string::npos) return;
    if (!c->Variables()) return;
    size_t i = 0;
    for (auto* v : *c->Variables())
        std::cout << tag << " " << nm << " var[" << i++ << "] " << tn(v) << " '"
                  << v->VpiName() << "'"
                  << " const=" << (int)v->VpiConstantVariable()
                  << " auto=" << (int)v->VpiAutomatic()
                  << " vis=" << v->VpiVisibility()
                  << " ts="
                  << (v->Typespec() && v->Typespec()->Actual_typespec()
                          ? tn(v->Typespec()->Actual_typespec())
                          : "-")
                  << " expr=" << (v->Expr() ? tn(v->Expr()) : "-") << "\n";
}

template <typename V>
static void doScope(const char* tag, const V* v) {
    if (!v) return;
    for (auto* p : *v)
        if (p->Class_defns())
            for (auto* cd : *p->Class_defns()) doClass(tag, cd);
}

int main(int argc, char** argv) {
    Serializer s;
    auto h = s.Restore(std::filesystem::path(argv[1]));
    const design* d = (const design*)((uhdm_handle*)h[0])->object;
    filt = argc > 2 ? argv[2] : "";
    doScope("DEFPKG", d->AllPackages());
    doScope("ELABPKG", d->TopPackages());
    if (d->AllClasses())
        for (auto* c : *d->AllClasses()) doClass("ALLCLS", c);
    return 0;
}
