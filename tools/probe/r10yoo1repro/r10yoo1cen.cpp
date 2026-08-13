// r10yoo1cen -- CENSUS of EVERY parameter's TYPESPEC in a UHDM database, keyed
// so the golden and ours can be joined cell-for-cell.
//
// WHY A CENSUS AND NOT A GREP.  The r10yoo1 head is ONE object, but its
// producer (ParamEmit.cpp's "untyped params with based-literal inits gain a
// bare [w-1:0] range" rule) fires on a WHOLE POPULATION.  Changing the rule
// without first counting who else it reaches is how a 52-line head becomes a
// 200-line regression.  So this prints one row per parameter, from BOTH
// databases, and the join reports EQ / DIF / MISSING -- never dropping a row,
// because a census that drops a row reads exactly like a census where the row
// agrees.
//
// The key is (VIEW, owner vpiFullName, param vpiName).  The VALUE is the four
// things this head disagrees on:
//     KIND   the typespec class            (logic_typespec vs int_typespec)
//     SPAN   line:col-endline:endcol       (spanless prints "-")
//     SIGNED vpiSigned
//     RANGE  each bound's ENCODING+value   (UINT:30 vs INT:30)
// all four in ONE field, so a single string compare decides the cell and no
// delta can hide behind a field this probe forgot to print.
//
// Build:
//   g++ -std=c++20 -O0 r10yoo1cen.cpp -o /tmp/r10yoo1cen \
//       -I$HOME/.local/include $HOME/.local/lib64/libuhdm.a \
//       $HOME/.local/lib64/libcapnp.a $HOME/.local/lib64/libkj.a -lpthread
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <map>
#include <string>
using namespace UHDM;

// A bound is printed with its ENCODING, because UINT:30 and INT:30 are the
// same NUMBER and a different OBJECT -- printing only the number is exactly the
// blindness that let this head sit unclassified.
static std::string bound(const any* e) {
    if (!e) return "<null>";
    if (e->UhdmType() == uhdmconstant) {
        auto* c = (const constant*)e;
        return std::string(c->VpiValue());  // already "UINT:30" / "INT:30"
    }
    if (e->UhdmType() == uhdmref_obj)
        return "ref(" + std::string(((const ref_obj*)e)->VpiName()) + ")";
    if (e->UhdmType() == uhdmoperation)
        return "op" + std::to_string(((const operation*)e)->VpiOpType());
    return UhdmName(e->UhdmType());
}

static std::string span(const BaseClass* o) {
    if (!o) return "-";
    if (o->VpiLineNo() == 0 && o->VpiColumnNo() == 0) return "-";  // SPANLESS
    return std::to_string(o->VpiLineNo()) + ":" +
           std::to_string(o->VpiColumnNo()) + "-" +
           std::to_string(o->VpiEndLineNo()) + ":" +
           std::to_string(o->VpiEndColumnNo());
}

static const VectorOfrange* rangesOf(const typespec* ts) {
    switch (ts->UhdmType()) {
        case uhdmint_typespec:     return ((const int_typespec*)ts)->Ranges();
        case uhdmlogic_typespec:   return ((const logic_typespec*)ts)->Ranges();
        case uhdmbit_typespec:     return ((const bit_typespec*)ts)->Ranges();
        // NOTE: integer_typespec has NO Ranges accessor in this UHDM build.
        case uhdmpacked_array_typespec:
            return ((const packed_array_typespec*)ts)->Ranges();
        case uhdmarray_typespec:   return ((const array_typespec*)ts)->Ranges();
        default: return nullptr;
    }
}

static bool signedOf(const typespec* ts) {
    switch (ts->UhdmType()) {
        case uhdmint_typespec:     return ((const int_typespec*)ts)->VpiSigned();
        case uhdmlogic_typespec:   return ((const logic_typespec*)ts)->VpiSigned();
        case uhdmbit_typespec:     return ((const bit_typespec*)ts)->VpiSigned();
        case uhdminteger_typespec: return ((const integer_typespec*)ts)->VpiSigned();
        default: return false;
    }
}

// KIND + SPAN + SIGNED + RANGE, one string.
static std::string describe(const typespec* ts) {
    if (!ts) return "<no-typespec>";
    std::string r = std::string(UhdmName(ts->UhdmType()));
    if (!std::string(ts->VpiName()).empty())
        r += "'" + std::string(ts->VpiName()) + "'";
    r += "@" + span(ts);
    if (signedOf(ts)) r += " signed";
    auto* rv = rangesOf(ts);
    if (!rv) r += " norange";
    else
        for (auto* rg : *rv)
            r += " [" + bound(rg->Left_expr()) + ":" +
                 bound(rg->Right_expr()) + "]@" + span(rg);
    return r;
}

static std::map<std::string, std::string>* OUT = nullptr;

static void emitParams(const VectorOfany* ps, const std::string& owner,
                       const char* view) {
    if (!ps) return;
    for (auto* p : *ps) {
        if (p->UhdmType() != uhdmparameter) continue;
        auto* pa = (const parameter*)p;
        const ref_typespec* rt = pa->Typespec();
        std::string key = std::string(view) + "|" + owner + "|" +
                          std::string(pa->VpiName());
        (*OUT)[key] = describe(rt ? rt->Actual_typespec() : nullptr);
    }
}

static void walkModule(const module_inst* m, const char* view) {
    emitParams((const VectorOfany*)m->Parameters(),
               std::string(m->VpiFullName()), view);
    if (m->Modules())
        for (auto* s : *m->Modules()) walkModule(s, view);
}

static void collect(const char* path, std::map<std::string, std::string>& out) {
    OUT = &out;
    Serializer ser;
    auto hs = ser.Restore(std::filesystem::path(path));
    if (hs.empty()) { std::cerr << "FATAL: no design in " << path << "\n"; exit(3); }
    auto* d = (design*)((uhdm_handle*)hs[0])->object;
    if (d->AllModules())   for (auto* m : *d->AllModules())   walkModule(m, "DEF");
    if (d->TopModules())   for (auto* m : *d->TopModules())   walkModule(m, "TOP");
    if (d->AllPackages())
        for (auto* p : *d->AllPackages())
            emitParams((const VectorOfany*)p->Parameters(),
                       "pkg:" + std::string(p->VpiName()), "DEFPKG");
    if (d->TopPackages())
        for (auto* p : *d->TopPackages())
            emitParams((const VectorOfany*)p->Parameters(),
                       "pkg:" + std::string(p->VpiName()), "TOPPKG");
}

int main(int argc, char** argv) {
    if (argc < 3) {
        std::cerr << "usage: r10yoo1cen <golden.uhdm> <ours.uhdm> [substr]\n";
        return 2;
    }
    std::string want = argc > 3 ? argv[3] : "";
    std::map<std::string, std::string> g, o;
    collect(argv[1], g);
    collect(argv[2], o);
    // Union of keys: a one-sided row is REPORTED, never dropped.
    std::map<std::string, int> keys;
    for (auto& [k, v] : g) keys[k] |= 1;
    for (auto& [k, v] : o) keys[k] |= 2;
    int eq = 0, dif = 0, missG = 0, missO = 0;
    for (auto& [k, w] : keys) {
        if (!want.empty() && k.find(want) == std::string::npos) continue;
        std::string gv = (w & 1) ? g[k] : "<ABSENT>";
        std::string ov = (w & 2) ? o[k] : "<ABSENT>";
        const char* verdict;
        if (!(w & 1)) { verdict = "MISSING-GOLDEN"; missG++; }
        else if (!(w & 2)) { verdict = "MISSING-OURS"; missO++; }
        else if (gv == ov) { verdict = "EQ"; eq++; }
        else { verdict = "DIF"; dif++; }
        printf("%-14s %-70s\n    GOLDEN %s\n    OURS   %s\n", verdict, k.c_str(),
               gv.c_str(), ov.c_str());
    }
    printf("CELLS %d   EQ %d   DIF %d   MISSING-GOLDEN %d   MISSING-OURS %d\n",
           eq + dif + missG + missO, eq, dif, missG, missO);
    return 0;
}
