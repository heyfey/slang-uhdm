// r10yoo1pa -- CENSUS of every PARAM_ASSIGN's Rhs-constant TYPESPEC, both
// views, keyed so golden and ours join cell-for-cell.
//
// WHY THIS PROBE AND NOT r10yoo1cen.  r10yoo1cen censused the PARAMETER's own
// typespec and reported 385 cells ALL EQUAL -- which REFUTED the brief's
// framing outright: the parameter's `int_typespec@86:4-88:24 [INT:30:INT:0]`
// is byte-for-byte what golden emits.  The head lives one slot over, on the
// `param_assign`'s Rhs CONSTANT's typespec, and only in the ELABORATED (TOP)
// view.  A census aimed at the wrong slot reports "all equal" in exactly the
// same words as a converged design, which is why the slot is now named in the
// key.
//
// KEY   VIEW | owner vpiFullName | Lhs parameter name
// VALUE the constant's own encoding AND its typespec's KIND/SPAN/RANGE, because
//       this head disagrees on three things at once (kind, bound encoding,
//       span) and printing only one of them would have hidden the other two.
//
// Build:
//   g++ -std=c++20 -O0 r10yoo1pa.cpp -o /tmp/r10yoo1pa \
//       -I$HOME/.local/include $HOME/.local/lib64/libuhdm.a \
//       $HOME/.local/lib64/libcapnp.a $HOME/.local/lib64/libkj.a -lpthread
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <map>
#include <string>
using namespace UHDM;

static std::string bound(const any* e) {
    if (!e) return "<null>";
    if (e->UhdmType() == uhdmconstant)
        return std::string(((const constant*)e)->VpiValue());
    if (e->UhdmType() == uhdmref_obj)
        return "ref(" + std::string(((const ref_obj*)e)->VpiName()) + ")";
    if (e->UhdmType() == uhdmoperation)
        return "op" + std::to_string(((const operation*)e)->VpiOpType());
    return UhdmName(e->UhdmType());
}

static std::string span(const BaseClass* o) {
    if (!o) return "-";
    if (o->VpiLineNo() == 0 && o->VpiColumnNo() == 0) return "SPANLESS";
    return std::to_string(o->VpiLineNo()) + ":" +
           std::to_string(o->VpiColumnNo()) + "-" +
           std::to_string(o->VpiEndLineNo()) + ":" +
           std::to_string(o->VpiEndColumnNo());
}

static const VectorOfrange* rangesOf(const typespec* ts) {
    switch (ts->UhdmType()) {
        case uhdmint_typespec:   return ((const int_typespec*)ts)->Ranges();
        case uhdmlogic_typespec: return ((const logic_typespec*)ts)->Ranges();
        case uhdmbit_typespec:   return ((const bit_typespec*)ts)->Ranges();
        case uhdmpacked_array_typespec:
            return ((const packed_array_typespec*)ts)->Ranges();
        default: return nullptr;
    }
}

static std::string describeTs(const typespec* ts) {
    if (!ts) return "<no-typespec>";
    std::string r = std::string(UhdmName(ts->UhdmType()));
    if (!std::string(ts->VpiName()).empty())
        r += "'" + std::string(ts->VpiName()) + "'";
    r += "@" + span(ts);
    auto* rv = rangesOf(ts);
    if (!rv) r += " norange";
    else
        for (auto* rg : *rv)
            r += " [" + bound(rg->Left_expr()) + ":" + bound(rg->Right_expr()) +
                 "]";
    return r;
}

static std::map<std::string, std::string>* OUT = nullptr;

static void emitPAs(const VectorOfparam_assign* pas, const std::string& owner,
                    const char* view) {
    if (!pas) return;
    for (auto* pa : *pas) {
        // Name the cell by the Lhs parameter -- the only stable identity a
        // param_assign has (it carries no name of its own).
        std::string lhs = "<no-lhs>";
        if (auto* l = pa->Lhs()) {
            if (!std::string(l->VpiName()).empty())
                lhs = std::string(l->VpiName());
            else
                lhs = std::string(UhdmName(l->UhdmType())) + "@" + span(l);
        }
        std::string val = "<no-rhs>";
        if (auto* r = pa->Rhs()) {
            val = std::string(UhdmName(r->UhdmType()));
            if (r->UhdmType() == uhdmconstant) {
                auto* c = (const constant*)r;
                val += " " + std::string(c->VpiValue()) + " sz=" +
                       std::to_string(c->VpiSize()) + " ct=" +
                       std::to_string(c->VpiConstType()) + " ts=";
                val += describeTs(c->Typespec() ? c->Typespec()->Actual_typespec()
                                                : nullptr);
            }
        }
        (*OUT)[std::string(view) + "|" + owner + "|" + lhs] = val;
    }
}

static void walkModule(const module_inst* m, const char* view) {
    emitPAs(m->Param_assigns(), std::string(m->VpiFullName()), view);
    if (m->Modules())
        for (auto* s : *m->Modules()) walkModule(s, view);
}

static void collect(const char* path, std::map<std::string, std::string>& out) {
    OUT = &out;
    Serializer ser;
    auto hs = ser.Restore(std::filesystem::path(path));
    if (hs.empty()) { std::cerr << "FATAL: no design in " << path << "\n"; exit(3); }
    auto* d = (design*)((uhdm_handle*)hs[0])->object;
    if (d->AllModules()) for (auto* m : *d->AllModules()) walkModule(m, "DEF");
    if (d->TopModules()) for (auto* m : *d->TopModules()) walkModule(m, "TOP");
    if (d->AllPackages())
        for (auto* p : *d->AllPackages())
            emitPAs(p->Param_assigns(), "pkg:" + std::string(p->VpiName()),
                    "DEFPKG");
    if (d->TopPackages())
        for (auto* p : *d->TopPackages())
            emitPAs(p->Param_assigns(), "pkg:" + std::string(p->VpiName()),
                    "TOPPKG");
}

int main(int argc, char** argv) {
    if (argc < 3) {
        std::cerr << "usage: r10yoo1pa <golden.uhdm> <ours.uhdm> [substr]\n";
        return 2;
    }
    std::string want = argc > 3 ? argv[3] : "";
    std::map<std::string, std::string> g, o;
    collect(argv[1], g);
    collect(argv[2], o);
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
        if (std::string(verdict) != "EQ" || !want.empty())
            printf("%-14s %s\n    GOLDEN %s\n    OURS   %s\n", verdict, k.c_str(),
                   gv.c_str(), ov.c_str());
    }
    printf("CELLS %d   EQ %d   DIF %d   MISSING-GOLDEN %d   MISSING-OURS %d\n",
           eq + dif + missG + missO, eq, dif, missG, missO);
    return 0;
}
