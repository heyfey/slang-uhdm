// r10uvmshape: dump the full recursive shape of one named class property
// (array_var / struct_var / ...) as CMP sees it, plus typespec chain.
//   r10uvmshape <file.uhdm> <classname> <propname>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <map>
#include <string>
using namespace UHDM;

static void ind(int n) { for (int i = 0; i < n; i++) std::cout << "  "; }

static void dumpTs(const typespec* t, int d, int depth);
void dumpExpr(const any* e, int d, int depth);

static void dumpVar(const BaseClass* v, int d, int depth) {
    if (!v || d > depth) return;
    ind(d);
    std::cout << UhdmName(v->UhdmType()) << " '" << v->VpiName() << "' @" << v->VpiLineNo() << ":"
              << v->VpiColumnNo() << "-" << v->VpiEndLineNo() << ":"
              << v->VpiEndColumnNo();
    if (auto* vv = any_cast<const variables*>(v)) {
        std::cout << " size=" << vv->VpiSize() << " auto=" << vv->VpiAutomatic()
                  << " vis=" << vv->VpiVisibility()
                  << " rand=" << vv->VpiRandType()
                  << " isrand=" << vv->VpiIsRandomized()
                  << " const=" << vv->VpiConstantVariable();
    }
    std::cout << "\n";
    if (auto* av = any_cast<const array_var*>(v)) {
        if (av->Typespec()) {
            ind(d + 1); std::cout << "Typespec ->\n";
            dumpTs(av->Typespec()->Actual_typespec(), d + 2, depth);
        }
        if (av->Variables())
            for (auto* e : *av->Variables()) {
                ind(d + 1); std::cout << "vpiReg:\n";
                dumpVar(e, d + 2, depth);
            }
        ind(d+1); std::cout << "av.VpiArrayType=" << av->VpiArrayType() << "\n";
        if (av->Ranges()) {
            ind(d+1); std::cout << "Ranges: " << av->Ranges()->size() << "\n";
            for (auto* r : *av->Ranges()) {
                ind(d+2);
                std::cout << "range @" << r->VpiLineNo() << ":" << r->VpiColumnNo() << "-"
                          << r->VpiEndLineNo() << ":" << r->VpiEndColumnNo()
                          << " vpiSize=" << r->VpiSize();
                const expr* ee[2] = {r->Left_expr(), r->Right_expr()};
                for (int k = 0; k < 2; k++) {
                    std::cout << (k ? " R=" : " L=");
                    if (!ee[k]) { std::cout << "-"; continue; }
                    std::cout << UhdmName(ee[k]->UhdmType()) << "{dec='"
                              << ee[k]->VpiDecompile() << "' sz=" << ee[k]->VpiSize();
                    if (auto* c = any_cast<const constant*>(ee[k]))
                        std::cout << " ct=" << c->VpiConstType() << " val='" << c->VpiValue() << "'";
                    std::cout << " @" << ee[k]->VpiLineNo() << ":" << ee[k]->VpiColumnNo()
                              << "-" << ee[k]->VpiEndLineNo() << ":" << ee[k]->VpiEndColumnNo();
                    if (auto* rt = ee[k]->Typespec()) {
                        auto* at = rt->Actual_typespec();
                        std::cout << " ts=" << (at ? UhdmName(at->UhdmType()) : "<null>")
                                  << "(" << (at ? at->VpiName() : "") << ")";
                    } else std::cout << " ts=<none>";
                    std::cout << "}";
                }
                std::cout << "\n";
            }
        }
    } else if (auto* vv = any_cast<const variables*>(v)) {
        if (vv->Typespec()) {
            ind(d + 1); std::cout << "Typespec ->\n";
            dumpTs(vv->Typespec()->Actual_typespec(), d + 2, depth);
        }
    }
    if (auto* vv = any_cast<const variables*>(v))
        if (auto* e = vv->Expr()) dumpExpr(e, d + 1, depth);
}

void dumpExpr(const any* e, int d, int depth) {
    if (!e || d > depth) return;
    ind(d);
    std::cout << "Expr " << UhdmName(e->UhdmType()) << " '" << e->VpiName() << "' @"
              << e->VpiLineNo() << ":" << e->VpiColumnNo() << "-" << e->VpiEndLineNo()
              << ":" << e->VpiEndColumnNo();
    if (auto* c = any_cast<const constant*>(e))
        std::cout << " ct=" << c->VpiConstType() << " val='" << c->VpiValue()
                  << "' dec='" << c->VpiDecompile() << "' sz=" << c->VpiSize();
    if (auto* o = any_cast<const operation*>(e))
        std::cout << " op=" << o->VpiOpType() << " dec='" << o->VpiDecompile()
                  << "' sz=" << o->VpiSize();
    if (auto* x = any_cast<const expr*>(e)) {
        if (auto* rt = x->Typespec()) {
            auto* a2 = rt->Actual_typespec();
            std::cout << " ts=" << (a2 ? UhdmName(a2->UhdmType()) : "<null>")
                      << "(" << (a2 ? a2->VpiName() : "") << ")";
        } else std::cout << " ts=<none>";
    }
    std::cout << "\n";
    if (auto* o = any_cast<const operation*>(e))
        if (o->Operands())
            for (auto* op : *o->Operands()) dumpExpr(op, d + 1, depth);
}

static void dumpTs(const typespec* t, int d, int depth) {
    if (!t) { ind(d); std::cout << "<null ts>\n"; return; }
    if (d > depth) { ind(d); std::cout << "...\n"; return; }
    ind(d);
    std::cout << UhdmName(t->UhdmType()) << " '" << t->VpiName() << "' @" << t->VpiLineNo() << ":"
              << t->VpiColumnNo() << "-" << t->VpiEndLineNo() << ":"
              << t->VpiEndColumnNo();
    if (auto* p = t->VpiParent())
        std::cout << " parent=" << UhdmName(p->UhdmType()) << "(" << p->VpiName() << ")";
    std::cout << "\n";
    if (auto* at = any_cast<const array_typespec*>(t)) {
        ind(d + 1); std::cout << "arraytype=" << at->VpiArrayType() << "\n";
        if (at->Elem_typespec()) {
            ind(d + 1); std::cout << "Elem_typespec ->\n";
            dumpTs(at->Elem_typespec()->Actual_typespec(), d + 2, depth);
        } else { ind(d+1); std::cout << "Elem_typespec: <none>\n"; }
        if (at->Index_typespec()) {
            ind(d + 1); std::cout << "Index_typespec ->\n";
            dumpTs(at->Index_typespec()->Actual_typespec(), d + 2, depth);
        }
        if (at->Ranges()) {
            ind(d+1); std::cout << "Ranges: " << at->Ranges()->size() << "\n";
            for (auto* r : *at->Ranges()) {
                ind(d+2);
                std::cout << "range @" << r->VpiLineNo() << ":" << r->VpiColumnNo() << "-"
                          << r->VpiEndLineNo() << ":" << r->VpiEndColumnNo();
                const expr* ee[2] = {r->Left_expr(), r->Right_expr()};
                for (int k = 0; k < 2; k++) {
                    std::cout << (k ? " R=" : " L=");
                    if (!ee[k]) { std::cout << "-"; continue; }
                    std::cout << UhdmName(ee[k]->UhdmType()) << "{dec='"
                              << ee[k]->VpiDecompile() << "' sz=" << ee[k]->VpiSize();
                    if (auto* c = any_cast<const constant*>(ee[k]))
                        std::cout << " ct=" << c->VpiConstType() << " val='" << c->VpiValue() << "'";
                    if (auto* rt2 = ee[k]->Typespec()) {
                        auto* a2 = rt2->Actual_typespec();
                        std::cout << " ts=" << (a2 ? UhdmName(a2->UhdmType()) : "<null>")
                                  << "(" << (a2 ? a2->VpiName() : "") << ")";
                    } else std::cout << " ts=<none>";
                    std::cout << " @" << ee[k]->VpiLineNo() << ":" << ee[k]->VpiColumnNo() << "}";
                }
                std::cout << "\n";
            }
        }
    }
    if (auto* st = any_cast<const struct_typespec*>(t)) {
        if (st->Members()) {
            ind(d+1); std::cout << "Members: " << st->Members()->size() << "\n";
            for (auto* m : *st->Members()) {
                ind(d+2); std::cout << "'" << m->VpiName() << "' @" << m->VpiLineNo() << ":" << m->VpiColumnNo() << "\n";
            }
        }
    }
}

static void collectClasses(design* d, std::map<std::string, class_defn*>& out) {
    if (d->AllClasses())
        for (auto* c : *d->AllClasses()) out[std::string(c->VpiName())] = c;
    if (d->TopPackages())
        for (auto* p : *d->TopPackages())
            if (p->Class_defns())
                for (auto* c : *p->Class_defns()) out.emplace(std::string(c->VpiName()), c);
}

int main(int argc, char** argv) {
    Serializer sa;
    auto ha = sa.Restore(std::filesystem::path(argv[1]));
    auto* da = (design*)((uhdm_handle*)ha[0])->object;
    std::map<std::string, class_defn*> ca;
    collectClasses(da, ca);
    std::string cn = argv[2], pn = argv[3];
    int depth = argc > 4 ? atoi(argv[4]) : 8;
    auto it = ca.find(cn);
    if (it == ca.end()) { std::cout << "class not found\n"; return 1; }
    auto* cd = it->second;
    if (cd->Variables())
        for (auto* v : *cd->Variables())
            if (std::string(v->VpiName()) == pn) dumpVar(v, 0, depth);
    if (pn == "@events" && cd->Named_events())
        for (auto* e : *cd->Named_events()) {
            std::cout << "named_event '" << e->VpiName() << "' @" << e->VpiLineNo() << ":" << e->VpiColumnNo() << "-"
                      << e->VpiEndLineNo() << ":" << e->VpiEndColumnNo()
                      << " parent=" << (e->VpiParent() ? UhdmName(e->VpiParent()->UhdmType()) : "<null>")
                      << " auto=" << e->VpiAutomatic() << " alloc=" << e->VpiAllocScheme()
                      << " arrmem=" << e->VpiArrayMember()
                      << " full='" << e->VpiFullName() << "'\n";
        }
    if (pn == "@ts" && cd->Typespecs())
        for (auto* t : *cd->Typespecs()) dumpTs(t, 0, depth);
    if (pn == "@der" && cd->Deriveds())
        for (auto* t : *cd->Deriveds())
            std::cout << "derived '" << t->VpiName() << "' @"
                      << t->VpiLineNo() << ":" << t->VpiColumnNo() << "\n";
    return 0;
}
