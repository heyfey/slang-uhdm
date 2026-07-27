// r7pkgmat: package-parameter TYPESPEC-RANGE bound form, per view.
// A `parameter logic [P-1:0] X` in a package has a logic_typespec whose range
// bounds Surelog may keep SYMBOLIC (op11{ref_obj->Actual, const}) or FOLD to a
// constant, and the choice differs between the DEF and TOP (elaborated) package
// views. This prints, for every package parameter in both views, the typespec's
// range-bound kind, plus whether a symbolic ref_obj carries vpiActual (the
// referenced param's own Rhs expression) — the CMP-relevant bit that
// `failLhs=constant failRhs=<null>` reports.
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <string>
using namespace UHDM;

static std::string loc(const BaseClass* o) {
    if (!o) return "-";
    return std::to_string(o->VpiLineNo()) + ":" + std::to_string(o->VpiColumnNo());
}

static void showExpr(const char* tag, const any* e, int ind) {
    std::string pad(ind, ' ');
    if (!e) {
        std::cout << pad << tag << " <null>\n";
        return;
    }
    std::cout << pad << tag << " " << UhdmName(e->UhdmType()) << "@" << loc(e);
    if (e->UhdmType() == uhdmconstant)
        std::cout << " '" << ((const constant*)e)->VpiDecompile() << "'";
    if (e->UhdmType() == uhdmref_obj) {
        auto* r = (const ref_obj*)e;
        std::cout << " name=" << r->VpiName() << " full=" << r->VpiFullName()
                  << " actual="
                  << (r->Actual_group()
                          ? std::string(UhdmName(r->Actual_group()->UhdmType())) +
                                "@" + loc(r->Actual_group())
                          : std::string("<null>"));
    }
    std::cout << "\n";
    if (e->UhdmType() == uhdmoperation)
        if (auto* ops = ((const operation*)e)->Operands())
            for (auto* o : *ops) showExpr("opnd", o, ind + 2);
}

static void showTs(const typespec* ts, int ind) {
    std::string pad(ind, ' ');
    if (!ts) { std::cout << pad << "ts <null>\n"; return; }
    std::cout << pad << "ts " << UhdmName(ts->UhdmType()) << "@" << loc(ts)
              << " inst=" << (ts->Instance() ? ts->Instance()->VpiName() : "-")
              << " parent="
              << (ts->VpiParent() ? UhdmName(ts->VpiParent()->UhdmType()) : "-")
              << "\n";
    if (ts->UhdmType() == uhdmlogic_typespec)
        if (auto* rs = ((const logic_typespec*)ts)->Ranges())
            for (auto* r : *rs) {
                showExpr("L", r->Left_expr(), ind + 2);
                showExpr("R", r->Right_expr(), ind + 2);
            }
}

static void dumpPkg(const package* p) {
    std::cout << "pkg " << p->VpiName() << (p->VpiTop() ? " [TOP]" : " [DEF]")
              << " @" << (const void*)p << "\n";
    if (auto* ps = p->Param_assigns()) {
        std::cout << "  Param_assigns " << ps->size() << "\n";
        for (auto* pa : *ps) {
            std::cout << "    pa lhs="
                      << (pa->Lhs() ? pa->Lhs()->VpiName() : "-") << " @"
                      << loc(pa) << " rhs=";
            if (auto* r = pa->Rhs())
                std::cout << UhdmName(r->UhdmType()) << "@" << loc(r);
            else
                std::cout << "<null>";
            std::cout << "\n";
        }
    }
    if (auto* pp = p->Parameters())
        for (auto* pv : *pp) {
            std::cout << "  param " << pv->VpiName() << " ("
                      << UhdmName(pv->UhdmType()) << ")\n";
            if (pv->UhdmType() == uhdmparameter)
                if (auto* rt = ((const parameter*)pv)->Typespec())
                    showTs(rt->Actual_typespec(), 4);
        }
}

int main(int argc, char** argv) {
    for (int i = 1; i < argc; i++) {
        Serializer s;
        auto h = s.Restore(std::filesystem::path(argv[i]));
        auto* d = (design*)((uhdm_handle*)h[0])->object;
        std::cout << "=== " << argv[i] << "\n";
        if (auto* v = d->AllPackages())
            for (auto* p : *v) dumpPkg(p);
        if (auto* v = d->TopPackages())
            for (auto* p : *v) dumpPkg(p);
    }
    return 0;
}
