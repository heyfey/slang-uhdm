// Compact typedef-forest probe: prints each package/module typedef with its
// members' ACTUAL typespecs expanded (uhdm-dump only summarises ref_typespec
// actuals, which hides bound-fold state and clone identity).
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <uhdm/vpi_visitor.h>

#include <cstdlib>
#include <filesystem>
#include <iostream>
#include <set>
#include <sstream>
#include <string>
using namespace UHDM;

static std::string g_filter;

static std::string loc(const any* o) {
    if (!o) return "-";
    return std::to_string(o->VpiLineNo()) + ":" +
           std::to_string(o->VpiColumnNo()) + "-" +
           std::to_string(o->VpiEndLineNo()) + ":" +
           std::to_string(o->VpiEndColumnNo());
}

static std::string owner(const any* o) {
    if (!o) return "-";
    const any* p = o->VpiParent();
    if (!p) return "NOPARENT";
    return std::string(UhdmName(p->UhdmType())) + "(" + std::string(p->VpiName()) + ")";
}

static std::string xpr(const any* e) {
    if (!e) return "-";
    switch (e->UhdmType()) {
        case uhdmconstant: {
            auto* c = (const constant*)e;
            return "C{d=" + std::string(c->VpiDecompile()) + ",sz" +
                   std::to_string(c->VpiSize()) + ",ct" +
                   std::to_string(c->VpiConstType()) + "," + loc(c) + "}";
        }
        case uhdmoperation: {
            auto* o = (const operation*)e;
            std::string s = "Op" + std::to_string(o->VpiOpType()) + "(";
            if (auto* ops = o->Operands())
                for (size_t i = 0; i < ops->size(); i++)
                    s += (i ? "," : "") + xpr((*ops)[i]);
            return s + ")@" + loc(o);
        }
        case uhdmref_obj: {
            auto* r = (const ref_obj*)e;
            std::string s = "R{" + std::string(r->VpiFullName());
            if (auto* a = r->Actual_group())
                s += "->" + std::string(UhdmName(a->UhdmType())) + "(" +
                     std::string(a->VpiName()) + ")@" + loc(a);
            else
                s += "->NULL";
            return s + "," + loc(r) + "}";
        }
        default:
            return std::string(UhdmName(e->UhdmType())) + "@" + loc(e);
    }
}

static void ts(std::ostream& os, const std::string& ind, const any* t, int depth,
               std::set<const any*>& seen);

static void ranges(std::ostream& os, const std::string& ind,
                   const VectorOfrange* rs) {
    if (!rs) return;
    for (auto* r : *rs)
        os << ind << "range " << loc(r) << " L=" << xpr(r->Left_expr())
           << " R=" << xpr(r->Right_expr()) << "\n";
}

static void ts(std::ostream& os, const std::string& ind, const any* t, int depth,
               std::set<const any*>& seen) {
    if (!t) { os << ind << "<null>\n"; return; }
    os << ind << UhdmName(t->UhdmType()) << " '" << t->VpiName() << "' "
       << loc(t) << " par=" << owner(t);
    if (auto* i = ((const typespec*)t)->Instance())
        os << " inst=" << i->VpiName()
           << (i->UhdmType() == uhdmpackage && ((const package*)i)->VpiTop()
                   ? "#TOP"
                   : "#DEF");
    os << "\n";
    if (depth <= 0) { os << ind << "  ...\n"; return; }
    if (!seen.insert(t).second) { os << ind << "  (revisit)\n"; return; }
    switch (t->UhdmType()) {
        case uhdmlogic_typespec: {
            auto* l = (const logic_typespec*)t;
            ranges(os, ind + "  ", l->Ranges());
            if (auto* a = l->Typedef_alias()) {
                os << ind << "  alias-> " << a->VpiFullName() << "\n";
                ts(os, ind + "    ", a->Actual_typespec(), depth - 1, seen);
            }
            break;
        }
        case uhdmbit_typespec:
            ranges(os, ind + "  ", ((const bit_typespec*)t)->Ranges());
            break;
        case uhdmarray_typespec:
            ranges(os, ind + "  ", ((const array_typespec*)t)->Ranges());
            if (auto* e = ((const array_typespec*)t)->Elem_typespec()) {
                os << ind << "  elem-> " << e->VpiFullName() << "\n";
                ts(os, ind + "    ", e->Actual_typespec(), depth - 1, seen);
            }
            break;
        case uhdmpacked_array_typespec:
            ranges(os, ind + "  ", ((const packed_array_typespec*)t)->Ranges());
            if (auto* e = ((const packed_array_typespec*)t)->Elem_typespec()) {
                os << ind << "  elem-> " << e->VpiFullName() << "\n";
                ts(os, ind + "    ", e->Actual_typespec(), depth - 1, seen);
            }
            break;
        case uhdmenum_typespec: {
            auto* en = (const enum_typespec*)t;
            if (auto* b = en->Base_typespec()) {
                os << ind << "  base-> " << b->VpiFullName() << "\n";
                ts(os, ind + "    ", b->Actual_typespec(), depth - 1, seen);
            }
            if (auto* a = en->Typedef_alias()) {
                os << ind << "  alias-> " << a->VpiFullName() << "\n";
                ts(os, ind + "    ", a->Actual_typespec(), depth - 1, seen);
            }
            if (auto* cs = en->Enum_consts())
                for (auto* c : *cs)
                    os << ind << "  const " << c->VpiName() << "="
                       << c->VpiValue() << " sz" << c->VpiSize() << " "
                       << loc(c) << " par=" << owner(c) << "\n";
            break;
        }
        case uhdmstruct_typespec:
        case uhdmunion_typespec: {
            const VectorOftypespec_member* ms =
                t->UhdmType() == uhdmstruct_typespec
                    ? ((const struct_typespec*)t)->Members()
                    : ((const union_typespec*)t)->Members();
            if (auto* a = t->UhdmType() == uhdmstruct_typespec
                              ? ((const struct_typespec*)t)->Typedef_alias()
                              : ((const union_typespec*)t)->Typedef_alias()) {
                os << ind << "  alias-> " << a->VpiFullName() << "\n";
                ts(os, ind + "    ", a->Actual_typespec(), depth - 1, seen);
            }
            if (ms)
                for (auto* m : *ms) {
                    os << ind << "  memb " << m->VpiName() << " " << loc(m)
                       << " par=" << owner(m) << "\n";
                    if (auto* rt = m->Typespec()) {
                        os << ind << "    ref '" << rt->VpiFullName()
                           << "' par=" << owner(rt) << "\n";
                        ts(os, ind + "      ", rt->Actual_typespec(), depth - 1,
                           seen);
                    }
                    else
                        os << ind << "    <no ref_typespec>\n";
                }
            break;
        }
        default:
            break;
    }
}

static void emit(const std::string& tag, const any* t) {
    if (!t) return;
    std::string nm(t->VpiName());
    if (!g_filter.empty() && nm.find(g_filter) == std::string::npos) return;
    std::set<const any*> seen;
    std::ostringstream ss;
    ts(ss, "  ", t, 6, seen);
    std::string pfx = tag + " " + nm + " |";
    std::istringstream is(ss.str());
    std::string ln;
    while (std::getline(is, ln)) std::cout << pfx << ln << "\n";
}

template <typename V>
static void doInst(const std::string& tag, V* insts) {
    if (!insts) return;
    int idx = 0;
    for (auto* p : *insts) {
        std::string pn(p->VpiName());
        std::string t0 = tag + "[" + std::to_string(idx) + ":" + pn + "]";
        if (!getenv("PROBE_TF"))
            if (auto* tds = p->Typespecs())
                for (auto* td : *tds) emit(t0, td);
        if (getenv("PROBE_TF"))
            if (auto* tfs = p->Task_funcs())
                for (auto* tf : *tfs) {
                    std::string fn(tf->VpiName());
                    if (tf->UhdmType() == uhdmfunction)
                        if (auto* rv = ((const function*)tf)->Return())
                            if (auto* rt = rv->Typespec())
                                emit(t0 + ".fn(" + fn + ").ret",
                                     rt->Actual_typespec());
                    if (auto* ios = tf->Io_decls())
                        for (auto* io : *ios)
                            if (auto* it = io->Typespec())
                                emit(t0 + ".fn(" + fn + ").io(" +
                                         std::string(io->VpiName()) + ")",
                                     it->Actual_typespec());
                }
        idx++;
    }
}

int main(int argc, char** argv) {
    if (argc < 2) { std::cerr << "usage: probe <uhdm> [name-substr]\n"; return 2; }
    if (argc > 2) g_filter = argv[2];
    Serializer s;
    auto hs = s.Restore(std::filesystem::path(argv[1]));
    auto* d = (design*)((uhdm_handle*)hs[0])->object;
    doInst("Pkg", d->AllPackages());
    doInst("TopPkg", d->TopPackages());
    doInst("AllMod", d->AllModules());
    doInst("TopMod", d->TopModules());
    return 0;
}
