// r10uvm30pv — the PACKAGE/MODULE-scope variable INITIALIZER census: every
// variable in every package and module view with the kind/name of its vpiExpr
// and, for a call, its argument count.  r10uvm29v did this for class_defn
// properties; the uhdm-cmp design head after pass 30's io_decl laws is the
// package-scope half of the same field (`uvm_table_printer
// uvm_default_table_printer = new()`).
//   r10uvm30pv <file.uhdm>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <string>
using namespace UHDM;

static std::string tn(const BaseClass* o) {
    return o ? std::string(UhdmName(o->UhdmType())) : std::string("-");
}

static std::string ex(const any* e) {
    if (!e) return "-";
    std::string o = tn(e) + " '" + std::string(e->VpiName()) + "'";
    if (const expr* x = any_cast<const expr*>(e)) {
        if (!x->VpiValue().empty()) o += " v=" + std::string(x->VpiValue());
        if (!x->VpiDecompile().empty())
            o += " d=" + std::string(x->VpiDecompile());
    }
    if (const method_func_call* m = any_cast<const method_func_call*>(e))
        o += " args=" +
             std::string(m->Tf_call_args()
                             ? std::to_string(m->Tf_call_args()->size())
                             : "none");
    if (const func_call* f = any_cast<const func_call*>(e))
        o += " args=" + std::string(f->Tf_call_args()
                                        ? std::to_string(
                                              f->Tf_call_args()->size())
                                        : "none");
    return o;
}

template <typename V>
static void doScope(const char* tag, const V* v) {
    if (!v) return;
    for (auto* p : *v) {
        std::string nm(p->VpiFullName().empty() ? p->VpiName()
                                                : p->VpiFullName());
        if (!p->Variables()) continue;
        for (auto* var : *p->Variables())
            std::cout << tag << " " << nm << "::" << var->VpiName() << " "
                      << tn(var) << " expr=" << ex(var->Expr()) << "\n";
    }
}

int main(int argc, char** argv) {
    Serializer s;
    auto h = s.Restore(std::filesystem::path(argv[1]));
    const design* d = (const design*)((uhdm_handle*)h[0])->object;
    doScope("DEFPKG", d->AllPackages());
    doScope("ELABPKG", d->TopPackages());
    doScope("DEFMOD", d->AllModules());
    doScope("TOPMOD", d->TopModules());
    return 0;
}
