// r10apsv: per-VIEW (allPackages vs topPackages) dump of every package
// function's unpacked-array local typespec range expression, plus the
// package's own Parameters/Param_assigns rhs. The uhdm-dump text prints a
// ref_typespec's Actual only as a one-line summary, so the fold state of a
// function-local array_typespec is invisible there — it only shows up in the
// weaklyReferenced tail, whose ORDER does not tell you which view produced
// it. This probe walks the two views explicitly.
// Build:
//   g++ -std=c++20 -O0 tools/probe/r10apsv.cpp -o /tmp/r10apsv \
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

static std::string xpr(const any* e) {
    if (!e) return "-";
    switch (e->UhdmType()) {
        case uhdmconstant: {
            auto* c = (const constant*)e;
            return "C{" + std::string(c->VpiDecompile()) + ",sz" +
                   std::to_string(c->VpiSize()) + ",ct" +
                   std::to_string(c->VpiConstType()) + "@" + loc(c) + "}";
        }
        case uhdmref_obj: {
            auto* r = (const ref_obj*)e;
            std::string a = "-";
            if (r->Actual_group())
                a = std::string(UhdmName(r->Actual_group()->UhdmType())) + "(" +
                    std::string(r->Actual_group()->VpiName()) + ")@" +
                    loc(r->Actual_group());
            return "R{" + std::string(r->VpiName()) + "->" + a + "@" + loc(r) + "}";
        }
        case uhdmoperation: {
            auto* o = (const operation*)e;
            std::string s = "OP" + std::to_string(o->VpiOpType()) + "@" + loc(o) + "(";
            if (o->Operands())
                for (auto* p : *o->Operands()) s += xpr(p) + " ";
            return s + ")";
        }
        case uhdmsys_func_call: {
            auto* c = (const sys_func_call*)e;
            std::string s = "SYS" + std::string(c->VpiName()) + "@" + loc(c) + "(";
            if (c->Tf_call_args())
                for (auto* p : *c->Tf_call_args()) s += xpr(p) + " ";
            return s + ")";
        }
        default:
            return std::string(UhdmName(e->UhdmType())) + "(" +
                   std::string(e->VpiName()) + ")@" + loc(e);
    }
}

static std::string tsx(const typespec* t);

static std::string refts(const ref_typespec* r) {
    if (!r) return "-";
    return tsx(r->Actual_typespec());
}

static std::string tsx(const typespec* t) {
    if (!t) return "<null-ts>";
    std::string s = std::string(UhdmName(t->UhdmType())) + "[" +
                    std::string(t->VpiName()) + "]@" + loc(t);
    if (t->Instance())
        s += " inst=" + std::string(t->Instance()->VpiName()) + "@" +
             loc(t->Instance());
    if (t->UhdmType() == uhdmarray_typespec) {
        auto* a = (const array_typespec*)t;
        if (a->Ranges())
            for (auto* r : *a->Ranges())
                s += "\n      range " + loc(r) + " L=" + xpr(r->Left_expr()) +
                     "\n        R=" + xpr(r->Right_expr());
        s += "\n      elem=" + refts(a->Elem_typespec());
    }
    if (t->UhdmType() == uhdmlogic_typespec) {
        auto* a = (const logic_typespec*)t;
        if (a->Ranges())
            for (auto* r : *a->Ranges())
                s += "\n      range " + loc(r) + " L=" + xpr(r->Left_expr()) +
                     " R=" + xpr(r->Right_expr());
    }
    if (t->UhdmType() == uhdmenum_typespec) {
        auto* a = (const enum_typespec*)t;
        s += "\n      base=" + refts(a->Base_typespec());
        if (a->Typedef_alias())
            s += "\n      alias->" + refts(a->Typedef_alias());
        if (a->Enum_consts())
            for (auto* c : *a->Enum_consts())
                s += "\n      const " + std::string(c->VpiName()) + "=" +
                     std::string(c->VpiDecompile()) + " sz" +
                     std::to_string(c->VpiSize());
    }
    return s;
}

static void dumpPkg(const std::string& tag, const package* p) {
    if (!p) return;
    std::cout << "== " << tag << " " << p->VpiName() << " top=" << p->VpiTop()
              << "\n";
    if (p->Parameters())
        for (auto* pa : *p->Parameters())
            std::cout << "  param " << pa->VpiName() << " ts="
                      << (pa->UhdmType() == uhdmparameter
                              ? refts(((const parameter*)pa)->Typespec())
                              : std::string("?"))
                      << "\n";
    if (p->Param_assigns())
        for (auto* pa : *p->Param_assigns())
            std::cout << "  passign " << (pa->Lhs() ? pa->Lhs()->VpiName() : "?")
                      << " = " << xpr(pa->Rhs()) << "\n";
    if (p->Typespecs())
        for (auto* t : *p->Typespecs())
            std::cout << "  pkgts " << tsx(t) << "\n";
    if (p->Task_funcs())
        for (auto* tf : *p->Task_funcs()) {
            std::cout << "  tf " << tf->VpiName() << "\n";
            if (tf->Variables())
                for (auto* v : *tf->Variables())
                    std::cout << "    var " << v->VpiName() << " ("
                              << UhdmName(v->UhdmType()) << ") ts="
                              << refts(v->Typespec()) << "\n";
        }
    if (p->Variables())
        for (auto* v : *p->Variables())
            std::cout << "  var " << v->VpiName() << " ("
                      << UhdmName(v->UhdmType()) << ") ts=" << refts(v->Typespec())
                      << "\n";
}

int main(int argc, char** argv) {
    if (argc < 2) {
        std::cout << "usage: r10apsv <file.uhdm> [pkgfilter]\n";
        return 1;
    }
    std::string filt = argc > 2 ? argv[2] : "";
    Serializer s;
    auto hs = s.Restore(std::filesystem::path(argv[1]));
    if (hs.empty()) {
        std::cout << "restore failed\n";
        return 1;
    }
    {
        auto* d = (design*)((uhdm_handle*)hs[0])->object;
        if (d->AllPackages())
            for (auto* p : *d->AllPackages())
                if (filt.empty() || std::string(p->VpiName()).find(filt) !=
                                        std::string::npos)
                    dumpPkg("ALL", p);
        if (d->TopPackages())
            for (auto* p : *d->TopPackages())
                if (filt.empty() || std::string(p->VpiName()).find(filt) !=
                                        std::string::npos)
                    dumpPkg("TOP", p);
        if (d->TopModules())
            for (auto* m : *d->TopModules()) {
                std::cout << "== MODULE " << m->VpiName() << "\n";
                if (m->Parameters())
                    for (auto* pa : *m->Parameters())
                        std::cout << "  param " << pa->VpiName() << " ts="
                                  << (pa->UhdmType() == uhdmparameter
                                          ? refts(((const parameter*)pa)->Typespec())
                                          : std::string("?"))
                                  << "\n";
                if (m->Param_assigns())
                    for (auto* pa : *m->Param_assigns())
                        std::cout << "  passign "
                                  << (pa->Lhs() ? pa->Lhs()->VpiName() : "?")
                                  << " = " << xpr(pa->Rhs()) << "\n";
                if (m->Typespecs())
                    for (auto* t : *m->Typespecs())
                        std::cout << "  modts " << tsx(t) << "\n";
            }
    }
    return 0;
}
