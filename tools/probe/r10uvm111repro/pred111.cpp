// pred111.cpp — r10uvm111 A-PRIORI MOVER PREDICTOR (measurement only).
//
// Reads ONE PRISTINE database and reports how many cells § pkgVarInitCmView-
// Clone111 would move in it, WITHOUT building anything: a cell is a package
// view whose Variables carry an initializer `func_call` that is bound to a
// CLASS_DEFN-parented method while that SAME view's Task_funcs listing holds a
// `C::m` entry with the func_call's exact VpiName.  That predicate is the law
// verbatim, so a database with 0 cells cannot move and a database with n cells
// must move exactly n func_call links.
//
//   usage: pred111 <design.uhdm>
//   prints: CELLS <n>            (and one WOULD row per cell)
#include <uhdm/uhdm.h>
#include <uhdm/Serializer.h>
#include <uhdm/vpi_user.h>
#include <cstdio>
#include <map>
#include <string>
#include <string_view>
#include <vector>
using namespace UHDM;

static long g_cells = 0;

static void walk(const any* e, const std::map<std::string, const function*>& by,
                 const package* pk, const char* view, const char* varName) {
    if (!e)
        return;
    if (e->UhdmType() == uhdmfunc_call) {
        auto* fc = (const func_call*)e;
        const function* cur = fc->Function();
        if (cur && cur->VpiParent() &&
            cur->VpiParent()->UhdmType() == uhdmclass_defn) {
            auto it = by.find(std::string(fc->VpiName()));
            if (it != by.end() && it->second != cur) {
                g_cells++;
                printf("WOULD %-4s pkg=%s var=%s call=%s from=#%u to=#%u\n",
                       view, std::string(pk->VpiName()).c_str(), varName,
                       std::string(fc->VpiName()).c_str(), cur->UhdmId(),
                       it->second->UhdmId());
            }
        }
        if (auto* as = fc->Tf_call_args())
            for (auto* a : *as)
                walk(a, by, pk, view, varName);
        return;
    }
    if (e->UhdmType() == uhdmoperation)
        if (auto* os = ((const operation*)e)->Operands())
            for (auto* o : *os)
                walk(o, by, pk, view, varName);
}

static void doPkg(const package* pk, const char* view) {
    if (!pk->Task_funcs() || !pk->Variables())
        return;
    std::map<std::string, const function*> by;
    for (auto* tf : *pk->Task_funcs()) {
        if (tf->UhdmType() != uhdmfunction)
            continue;
        std::string n(tf->VpiName());
        if (n.find("::") == std::string::npos)
            continue;
        by.emplace(n, (const function*)tf);
    }
    if (by.empty())
        return;
    for (auto* v : *pk->Variables())
        walk(v->Expr(), by, pk, view, std::string(v->VpiName()).c_str());
}

int main(int argc, char** argv) {
    if (argc < 2) {
        fprintf(stderr, "usage: pred111 <design.uhdm>\n");
        return 2;
    }
    Serializer s;
    std::vector<vpiHandle> restored = s.Restore(std::string(argv[1]));
    if (restored.empty()) {
        fprintf(stderr, "FATAL: nothing restored from %s\n", argv[1]);
        return 3;
    }
    for (auto h : restored) {
        auto* d = (design*)((uhdm_handle*)h)->object;
        if (auto* ps = d->AllPackages())
            for (auto* p : *ps)
                doPkg(p, "DEF");
        if (auto* ps = d->TopPackages())
            for (auto* p : *ps)
                doPkg(p, "TOP");
    }
    printf("CELLS %ld\n", g_cells);
    return 0;
}
