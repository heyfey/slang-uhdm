// r10uvm29v — CLASS-PROPERTY INITIALIZER census: for every class_defn
// reachable from AllPackages / TopPackages / AllClasses (and module-local
// class lists), print each Variables entry together with a RECURSIVE
// projection of its `vpiExpr` initializer onto the fields uhdm-cmp actually
// reads (kind, name, defname, decompile, size, constType, op-type, the
// tf_call Function()/Scope() pointers, ref_obj Actual_group), plus the
// line:col span so the shape can be matched back to the source.
//
// The projection behind pass 29's § class-property inline initializers: the
// emitter's initializer arm is a whitelist of expression kinds and everything
// else is silently dropped, so a census of Expr KINDS per property is the
// only way to see which declarations golden materialises.
//
//   r10uvm29v <file.uhdm> [nameFilter]
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
static std::string filt;
static std::set<const class_defn*> seen;

static std::string loc(const BaseClass* o) {
    if (!o) return "-";
    return std::to_string(o->VpiLineNo()) + ":" +
           std::to_string(o->VpiColumnNo());
}

// One line per expression node, indented by depth.
static void doExpr(const std::string& pfx, const any* e, int depth) {
    if (!e || depth > 6) return;
    std::string ind(2 * depth, ' ');
    std::cout << pfx << " " << ind << tn(e) << " '" << e->VpiName() << "'";
    if (const expr* x = any_cast<const expr*>(e)) {
        if (!x->VpiDecompile().empty())
            std::cout << " dec='" << x->VpiDecompile() << "'";
        if (x->VpiSize()) std::cout << " sz=" << x->VpiSize();
        std::cout << " ts="
                  << (x->Typespec() && x->Typespec()->Actual_typespec()
                          ? tn(x->Typespec()->Actual_typespec())
                          : "-");
    }
    if (const constant* c = any_cast<const constant*>(e))
        std::cout << " ct=" << c->VpiConstType() << " val='" << c->VpiValue()
                  << "'";
    if (const ref_obj* r = any_cast<const ref_obj*>(e))
        std::cout << " defn='" << r->VpiDefName() << "'"
                  << " act=" << tn(r->Actual_group()) << ":'"
                  << (r->Actual_group() ? r->Actual_group()->VpiName() : "")
                  << "'";
    if (const operation* o = any_cast<const operation*>(e))
        std::cout << " op=" << o->VpiOpType();
    if (const tf_call* t = any_cast<const tf_call*>(e)) {
        std::cout << " nargs="
                  << (t->Tf_call_args() ? (int)t->Tf_call_args()->size() : -1)
                  << " scope=" << tn(t->Scope());
        if (const func_call* f = any_cast<const func_call*>(e))
            std::cout << " ftype=" << f->VpiFuncType()
                      << " fn=" << (f->Function() ? "Y" : "-");
        if (const method_func_call* m = any_cast<const method_func_call*>(e))
            std::cout << " udef=" << (int)m->VpiUserDefn()
                      << " pfx=" << tn(m->Prefix())
                      << " fn=" << (m->Function() ? "Y" : "-");
    }
    std::cout << " @" << loc(e) << "\n";
    if (const operation* o = any_cast<const operation*>(e))
        if (o->Operands())
            for (auto* op : *o->Operands()) doExpr(pfx, op, depth + 1);
    if (const tf_call* t = any_cast<const tf_call*>(e))
        if (t->Tf_call_args())
            for (auto* a : *t->Tf_call_args()) doExpr(pfx, a, depth + 1);
}

static void doClass(const char* tag, const class_defn* c) {
    if (!c || !seen.insert(c).second) return;
    std::string nm(c->VpiFullName().empty() ? c->VpiName() : c->VpiFullName());
    if (!filt.empty() && nm.find(filt) == std::string::npos) return;
    if (!c->Variables()) return;
    size_t i = 0;
    for (auto* v : *c->Variables()) {
        std::string pfx = std::string(tag) + " " + nm + " var[" +
                          std::to_string(i++) + "]";
        std::cout << pfx << " " << tn(v) << " '" << v->VpiName() << "' @"
                  << loc(v) << " expr=" << (v->Expr() ? tn(v->Expr()) : "-")
                  << "\n";
        if (v->Expr()) doExpr(pfx + "   .expr", v->Expr(), 0);
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
    filt = argc > 2 ? argv[2] : "";
    doScope("DEFPKG", d->AllPackages());
    doScope("ELABPKG", d->TopPackages());
    if (d->AllClasses())
        for (auto* c : *d->AllClasses()) doClass("ALLCLS", c);
    if (d->AllModules())
        for (auto* m : *d->AllModules())
            if (m->Class_defns())
                for (auto* cd : *m->Class_defns()) doClass("ALLMOD", cd);
    if (d->TopModules())
        for (auto* m : *d->TopModules())
            if (m->Class_defns())
                for (auto* cd : *m->Class_defns()) doClass("TOPMOD", cd);
    return 0;
}
