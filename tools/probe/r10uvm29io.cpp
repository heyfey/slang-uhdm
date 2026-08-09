// r10uvm29io — io_decl DEFAULT-VALUE census: every class method's io_decls
// with the kind of their vpiExpr.  Written as the control for pass 29: once
// § classPropInit29 cleared the class_var head, the localizer's next row was
// an EXTRA `ref_obj 'UVM_NORADIX'` on a FORMAL default, and the only honest
// way to say "pre-existing, newly exposed" rather than "mine" is to diff this
// projection of the pre- and post-patch databases.
//   r10uvm29io <file.uhdm>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <set>
#include <string>
using namespace UHDM;

static std::string tn(const BaseClass* o) {
    return o ? std::string(UhdmName(o->UhdmType())) : std::string("-");
}
static std::set<const class_defn*> seen;

static void doClass(const char* tag, const class_defn* c) {
    if (!c || !seen.insert(c).second) return;
    std::string nm(c->VpiFullName().empty() ? c->VpiName() : c->VpiFullName());
    if (!c->Task_funcs()) return;
    for (auto* tf : *c->Task_funcs()) {
        if (!tf->Io_decls()) continue;
        size_t i = 0;
        for (auto* io : *tf->Io_decls())
            std::cout << tag << " " << nm << "::" << tf->VpiName() << " io["
                      << i++ << "] '" << io->VpiName() << "' expr="
                      << (io->Expr() ? tn(io->Expr()) : "-") << " '"
                      << (io->Expr() ? io->Expr()->VpiName() : "") << "'\n";
    }
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
    doScope("DEFPKG", d->AllPackages());
    doScope("ELABPKG", d->TopPackages());
    if (d->AllClasses())
        for (auto* c : *d->AllClasses()) doClass("ALLCLS", c);
    return 0;
}
