// r10uvmav: print a package array_var's typespec / element structure in full.
//   r10uvmav <db.uhdm> <pkgname> <varname>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <string>
using namespace UHDM;

static void ind(int n) { for (int i = 0; i < n; i++) std::cout << "  "; }

static void pts(const typespec* t, int d);

static void pexpr(const any* e, int d) {
    if (!e) { ind(d); std::cout << "<null>\n"; return; }
    ind(d);
    std::cout << UhdmName(e->UhdmType()) << " name=" << e->VpiName();
    if (e->UhdmType() == uhdmconstant) {
        auto* c = (constant*)e;
        std::cout << " ct=" << c->VpiConstType() << " dec=" << c->VpiDecompile()
                  << " sz=" << c->VpiSize() << " val=" << c->VpiValue();
    }
    std::cout << " @" << e->VpiLineNo() << ":" << e->VpiColumnNo() << "-"
              << e->VpiEndLineNo() << ":" << e->VpiEndColumnNo() << "\n";
}

static void pts(const typespec* t, int d) {
    if (!t) { ind(d); std::cout << "<null ts>\n"; return; }
    ind(d);
    std::cout << UhdmName(t->UhdmType()) << " name='" << t->VpiName() << "'"
              << " inst=" << (t->Instance() ? std::string(t->Instance()->VpiName()) : "-")
              << " @" << t->VpiLineNo() << ":" << t->VpiColumnNo() << "-"
              << t->VpiEndLineNo() << ":" << t->VpiEndColumnNo() << "\n";
    if (t->UhdmType() == uhdmclass_typespec) {
        auto* c = (class_typespec*)t;
        ind(d + 1);
        std::cout << "Class_defn=" << (c->Class_defn() ? std::string(c->Class_defn()->VpiName()) : "<null>")
                  << " params=" << (c->Parameters() ? c->Parameters()->size() : 0) << "\n";
    }
    if (t->UhdmType() == uhdmarray_typespec) {
        auto* a = (array_typespec*)t;
        ind(d + 1); std::cout << "arrayType=" << a->VpiArrayType() << "\n";
        if (a->Ranges())
            for (auto* r : *a->Ranges()) {
                ind(d + 1); std::cout << "range @" << r->VpiLineNo() << ":"
                                      << r->VpiColumnNo() << "-" << r->VpiEndLineNo()
                                      << ":" << r->VpiEndColumnNo() << "\n";
                pexpr(r->Left_expr(), d + 2);
                pexpr(r->Right_expr(), d + 2);
            }
        else { ind(d + 1); std::cout << "no ranges\n"; }
        ind(d + 1);
        std::cout << "elem=" << (a->Elem_typespec() ? "y" : "n")
                  << " index=" << (a->Index_typespec() ? "y" : "n")
                  << " alias=" << (a->Typedef_alias() ? "y" : "n") << "\n";
        if (a->Index_typespec()) {
            ind(d + 1); std::cout << "Index_typespec:\n";
            pts(a->Index_typespec()->Actual_typespec(), d + 2);
        }
        if (a->Elem_typespec()) {
            ind(d + 1); std::cout << "Elem_typespec:\n";
            pts(a->Elem_typespec()->Actual_typespec(), d + 2);
        }
    }
}

static void pvar(const variables* v, int d) {
    ind(d);
    std::cout << UhdmName(v->UhdmType()) << " '" << v->VpiName() << "' full='"
              << v->VpiFullName() << "' size=" << v->VpiSize()
              << " arrType="
              << (v->UhdmType() == uhdmarray_var ? ((array_var*)v)->VpiArrayType() : -1)
              << " auto=" << v->VpiAutomatic()
              << " vis=" << v->VpiVisibility() << " rand=" << v->VpiRandType()
              << " @" << v->VpiLineNo() << ":" << v->VpiColumnNo() << "-"
              << v->VpiEndLineNo() << ":" << v->VpiEndColumnNo() << "\n";
    if (v->Typespec()) {
        ind(d + 1); std::cout << "Typespec ref full='" << v->Typespec()->VpiFullName() << "'\n";
        pts(v->Typespec()->Actual_typespec(), d + 2);
    }
    if (v->UhdmType() == uhdmarray_var) {
        auto* a = (array_var*)v;
        if (a->Variables())
            for (auto* e : *a->Variables()) { ind(d + 1); std::cout << "vpiReg:\n"; pvar(e, d + 2); }
    }
}

static const package* find(const design* d, const std::string& n) {
    if (!d->AllPackages()) return nullptr;
    for (auto* p : *d->AllPackages())
        if (std::string(p->VpiName()) == n) return p;
    return nullptr;
}

int main(int argc, char** argv) {
    Serializer sa;
    auto ha = sa.Restore(std::filesystem::path(argv[1]));
    auto* da = (design*)((uhdm_handle*)ha[0])->object;
    const package* a = find(da, argv[2]);
    if (!a || !a->Variables()) { std::cout << "not found\n"; return 1; }
    std::string want = argv[3];
    for (auto* v : *a->Variables())
        if (want == "*" || std::string(v->VpiName()) == want) pvar(v, 0);
    return 0;
}
