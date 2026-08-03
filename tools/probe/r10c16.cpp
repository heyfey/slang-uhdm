// r10c16: per-VIEW (allPackages / topPackages / allModules / topModules)
// census of PARAMETER typespecs, printing UhdmId for every object so object
// SHARING between views is visible (uhdm-dump abbreviates a repeat visit, so
// "same text" there does not mean "same object"), plus the full range/elem
// chain of a packed_array_typespec — the shape C16 has to reproduce.
// Build:
//   g++ -std=c++20 -O0 tools/probe/r10c16.cpp -o /tmp/r10c16p \
//       -I$HOME/.local/include $HOME/.local/lib64/libuhdm.a \
//       $HOME/.local/lib64/libcapnp.a $HOME/.local/lib64/libkj.a -lpthread
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <string>
using namespace UHDM;

static std::string loc(const any* o) {
    if (!o) return "-";
    return std::to_string(o->VpiLineNo()) + ":" +
           std::to_string(o->VpiColumnNo()) + "-" +
           std::to_string(o->VpiEndLineNo()) + ":" +
           std::to_string(o->VpiEndColumnNo());
}
static std::string id(const any* o) {
    if (!o) return "-";
    return "#" + std::to_string(o->UhdmId());
}

static std::string xpr(const any* e) {
    if (!e) return "-";
    switch (e->UhdmType()) {
        case uhdmconstant: {
            auto* c = (const constant*)e;
            return "C" + id(c) + "{" + std::string(c->VpiDecompile()) + ",sz" +
                   std::to_string(c->VpiSize()) + ",ct" +
                   std::to_string(c->VpiConstType()) + ",v=" +
                   std::string(c->VpiValue()) + "@" + loc(c) + "}";
        }
        case uhdmref_obj: {
            auto* r = (const ref_obj*)e;
            std::string a = "-";
            if (r->Actual_group())
                a = std::string(UhdmName(r->Actual_group()->UhdmType())) + "(" +
                    std::string(r->Actual_group()->VpiName()) + ")" +
                    id(r->Actual_group()) + "@" + loc(r->Actual_group());
            return "R" + id(r) + "{" + std::string(r->VpiName()) + "|fn=" +
                   std::string(r->VpiFullName()) + "->" + a + "@" + loc(r) + "}";
        }
        case uhdmoperation: {
            auto* o = (const operation*)e;
            std::string s = "OP" + std::to_string(o->VpiOpType()) + id(o) + "@" +
                            loc(o) + "(";
            if (o->Operands())
                for (auto* p : *o->Operands()) s += xpr(p) + " ";
            return s + ")";
        }
        default:
            return std::string(UhdmName(e->UhdmType())) + id(e) + "(" +
                   std::string(e->VpiName()) + ")@" + loc(e);
    }
}

static std::string tsx(const typespec* t, int depth);

static std::string refts(const ref_typespec* r, int depth) {
    if (!r) return "-";
    return "ref" + id(r) + "[nm=" + std::string(r->VpiName()) + ",fn=" +
           std::string(r->VpiFullName()) + "]->" +
           tsx(r->Actual_typespec(), depth);
}

static std::string rangeStr(const VectorOfrange* rs, int depth) {
    std::string pad(2 * depth + 6, ' ');
    std::string s;
    if (!rs) return s;
    for (auto* r : *rs)
        s += "\n" + pad + "range" + id(r) + "@" + loc(r) +
             " L=" + xpr(r->Left_expr()) + "\n" + pad + "      R=" +
             xpr(r->Right_expr());
    return s;
}

static std::string tsx(const typespec* t, int depth) {
    if (!t) return "<null-ts>";
    if (depth > 4) return "...";
    std::string pad(2 * depth + 6, ' ');
    std::string s = std::string(UhdmName(t->UhdmType())) + id(t) + "[" +
                    std::string(t->VpiName()) + "]@" + loc(t);
    if (t->Instance())
        s += " inst=" + std::string(t->Instance()->VpiName()) +
             id(t->Instance());
    switch (t->UhdmType()) {
        case uhdmpacked_array_typespec: {
            auto* a = (const packed_array_typespec*)t;
            s += rangeStr(a->Ranges(), depth);
            s += "\n" + pad + "elem=" + refts(a->Elem_typespec(), depth + 1);
            if (a->Typedef_alias())
                s += "\n" + pad + "alias=" +
                     refts(a->Typedef_alias(), depth + 1);
            break;
        }
        case uhdmarray_typespec: {
            auto* a = (const array_typespec*)t;
            s += rangeStr(a->Ranges(), depth);
            s += "\n" + pad + "elem=" + refts(a->Elem_typespec(), depth + 1);
            break;
        }
        case uhdmlogic_typespec:
            s += rangeStr(((const logic_typespec*)t)->Ranges(), depth);
            break;
        case uhdmbit_typespec:
            s += rangeStr(((const bit_typespec*)t)->Ranges(), depth);
            break;
        case uhdmstruct_typespec: {
            auto* st = (const struct_typespec*)t;
            if (st->Members())
                for (auto* m : *st->Members())
                    s += "\n" + pad + "mem " + std::string(m->VpiName()) +
                         id(m) + " ts=" + refts(m->Typespec(), depth + 1);
            break;
        }
        case uhdmenum_typespec: {
            auto* et = (const enum_typespec*)t;
            s += "\n" + pad + "base=" + refts(et->Base_typespec(), depth + 1);
            break;
        }
        default:
            break;
    }
    return s;
}

static void dumpScope(const std::string& tag, const std::string& nm,
                      const VectorOfany* params,
                      const VectorOfparam_assign* pas) {
    std::cout << "== " << tag << " " << nm << "\n";
    if (params)
        for (auto* pa : *params) {
            if (pa->UhdmType() != uhdmparameter) {
                std::cout << "  " << UhdmName(pa->UhdmType()) << " "
                          << pa->VpiName() << id(pa) << "\n";
                continue;
            }
            auto* p = (const parameter*)pa;
            std::cout << "  param " << p->VpiName() << id(p) << "@" << loc(p)
                      << " val=" << std::string(p->VpiValue()) << "\n    ts="
                      << refts(p->Typespec(), 0) << "\n";
        }
    if (pas)
        for (auto* pa : *pas)
            std::cout << "  passign" << id(pa) << " "
                      << (pa->Lhs() ? pa->Lhs()->VpiName() : "?") << " = "
                      << xpr(pa->Rhs()) << "\n";
}

int main(int argc, char** argv) {
    if (argc < 2) return 1;
    Serializer ser;
    std::vector<vpiHandle> restored = ser.Restore(std::string(argv[1]));
    if (restored.empty()) return 2;
    design* d = (design*)((uhdm_handle*)restored[0])->object;
    auto pkgs = [&](const std::string& tag, VectorOfpackage* v) {
        if (!v) return;
        for (auto* p : *v) {
            if (std::string(p->VpiName()) == "builtin") continue;
            dumpScope(tag + "-pkg", std::string(p->VpiName()) +
                                        " top=" + std::to_string(p->VpiTop()),
                      p->Parameters(), p->Param_assigns());
            if (p->Typespecs())
                for (auto* t : *p->Typespecs())
                    std::cout << "  pkgtypedef " << tsx(t, 0) << "\n";
        }
    };
    pkgs("ALL", d->AllPackages());
    pkgs("TOP", d->TopPackages());
    auto mods = [&](const std::string& tag, VectorOfmodule_inst* v) {
        if (!v) return;
        for (auto* m : *v)
            dumpScope(tag + "-mod", std::string(m->VpiFullName()),
                      m->Parameters(), m->Param_assigns());
    };
    mods("ALL", d->AllModules());
    mods("TOP", d->TopModules());
    return 0;
}
