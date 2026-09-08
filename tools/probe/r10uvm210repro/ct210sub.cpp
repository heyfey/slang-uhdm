// r10uvm210 — SUB-OBJECT COMPARE.  MEASUREMENT ONLY; the official
// `~/git-repos/UHDM/build/bin/uhdm-cmp` on the whole design is the sole
// acceptance judge and every accept/reject number in this pass comes from it.
// This tool exists for ONE decoding question the whole-design log cannot
// answer: uhdm-cmp prints the failed PAIR but not the ROUTE, and this pass's
// head pairs a GOLDEN object that lives under the DEF package with an OURS
// object that lives under the ELAB package.  Running the SAME generated
// `Compare` on a named sub-object with a fresh CompareContext says which
// listing actually disagrees.
//
//   ct210sub <golden.uhdm> <ours.uhdm> <what>
//     what = allpkg:<name> | toppkg:<name> | allmod:<idx> | topmod:<idx>
//            | class:<name>            (design->AllClasses, by VpiName)
//
// LHS is ALWAYS golden; RHS is ALWAYS ours.
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <cstdio>
#include <cstring>
#include <cstdlib>
#include <string>
#include <vector>
#include <vector>

using namespace UHDM;

static const design* theDesign(Serializer& s) {
    for (auto& kv : s.AllObjects())
        if (kv.first && kv.first->UhdmType() == uhdmdesign)
            return (const design*)kv.first;
    return nullptr;
}

static const BaseClass* pick(const design* d, const std::string& what) {
    auto byName = [&](const std::vector<package*>* v, const std::string& n)
        -> const BaseClass* {
        if (!v) return nullptr;
        for (auto* x : *v)
            if (std::string(x->VpiName()) == n) return x;
        return nullptr;
    };
    if (what.rfind("allpkg:", 0) == 0)
        return byName(d->AllPackages(), what.substr(7));
    if (what.rfind("toppkg:", 0) == 0)
        return byName(d->TopPackages(), what.substr(7));
    if (what.rfind("class:", 0) == 0) {
        if (!d->AllClasses()) return nullptr;
        for (auto* x : *d->AllClasses())
            if (std::string(x->VpiName()) == what.substr(6)) return x;
        return nullptr;
    }
    if (what.rfind("allmod:", 0) == 0) {
        if (!d->AllModules()) return nullptr;
        size_t i = strtoul(what.c_str() + 7, nullptr, 10);
        return i < d->AllModules()->size() ? (*d->AllModules())[i] : nullptr;
    }
    if (what.rfind("topmod:", 0) == 0) {
        if (!d->TopModules()) return nullptr;
        size_t i = strtoul(what.c_str() + 7, nullptr, 10);
        return i < d->TopModules()->size() ? (*d->TopModules())[i] : nullptr;
    }
    return nullptr;
}

// NOTE: `UhdmName()` and `VpiName()` are read through the OWNING Serializer's
// symbol table.  This tool holds TWO live Serializers at once and the failed
// pair straddles them, so the names printed here came out as binary garbage the
// first time.  Everything below is read from the object header only — the
// numeric UhdmType, the UhdmId and the span — which is enough: `ct210own --id`
// on the same database resolves the id to a named parent chain.
static std::string face(const BaseClass* o) {
    if (!o) return "<null>";
    char b[200];
    snprintf(b, sizeof b, "type=%d id=%u @%u:%u-%u:%u",
             (int)o->UhdmType(), (unsigned)o->UhdmId(), o->VpiLineNo(),
             (unsigned)o->VpiColumnNo(), o->VpiEndLineNo(),
             (unsigned)o->VpiEndColumnNo());
    return b;
}


// CELL MODE.  `pas:<sel>` walks the picked scope's Param_assigns index by index
// and runs the OFFICIAL generated `param_assign::Compare` on each pair with a
// FRESH CompareContext, printing every index that differs.  A whole-object
// compare stops at the first failure and its m_visited then hides every later
// one; this says how many cells of the listing actually disagree, which is what
// a census needs.  `vars:<sel>` does the same for Variables, `pars:` for
// Parameters, `tss:` for Typespecs.
static void one(const char* tag, size_t i, const BaseClass* l, const BaseClass* r,
                int& bad) {
    if (!l || !r) { printf("  %s[%zu] NULLSIDE l=%p r=%p\n", tag, i, (void*)l, (void*)r); ++bad; return; }
    CompareContext c;
    int32_t rr = l->Compare(r, &c);
    if (rr == 0) return;
    ++bad;
    printf("  %s[%zu] r=%d  L %s  R %s  FAILL %s  FAILR %s\n", tag, i, (int)rr,
           face(l).c_str(), face(r).c_str(), face(c.m_failedLhs).c_str(),
           face(c.m_failedRhs).c_str());
}

// ONLY=<TAG>[,<TAG>...] in the environment restricts the cell walk to those
// listings.  TASK_FUNCS on a UVM package is 894 subroutine bodies and takes
// minutes; the param_assign question needs one listing.
static bool wanted(const char* tag) {
    const char* only = getenv("ONLY");
    if (!only || !*only) return true;
    size_t n = strlen(tag);
    for (const char* p = only; *p;) {
        const char* e = strchr(p, ',');
        size_t len = e ? (size_t)(e - p) : strlen(p);
        if (len == n && strncmp(p, tag, n) == 0) return true;
        if (!e) break;
        p = e + 1;
    }
    return false;
}

template <class V>
static void vecCells(const char* tag, const V* lv, const V* rv) {
    if (!wanted(tag)) return;
    if (!lv && !rv) { printf("-- %s BOTH-EMPTY\n", tag); return; }
    if (!lv || !rv) { printf("-- %s ONE-EMPTY l=%p r=%p\n", tag, (void*)lv, (void*)rv); return; }
    printf("-- %s sizes L=%zu R=%zu\n", tag, lv->size(), rv->size());
    size_t n = lv->size() < rv->size() ? lv->size() : rv->size();
    int bad = 0;
    for (size_t i = 0; i < n; ++i) one(tag, i, (*lv)[i], (*rv)[i], bad);
    printf("-- %s DIFFERING %d / %zu\n", tag, bad, n);
}

// CELL MODE.  Walk each of the picked scope's listings index by index and run
// the OFFICIAL generated `Compare` on each pair with a FRESH CompareContext.
// A whole-object compare stops at the first failure and its m_visited then
// hides every later one; this says which LISTING and which CELL disagree, which
// is what a census needs and what the cmp log cannot say.
static int cells(const BaseClass* L, const BaseClass* R) {
    const scope* ls = any_cast<const scope*>(L);
    const scope* rs = any_cast<const scope*>(R);
    if (!ls || !rs) { printf("NOT_A_SCOPE\n"); return 1; }
    vecCells("VARIABLES", ls->Variables(), rs->Variables());
    vecCells("PARAMETERS", ls->Parameters(), rs->Parameters());
    vecCells("PARAM_ASSIGNS", ls->Param_assigns(), rs->Param_assigns());
    vecCells("TYPESPECS", ls->Typespecs(), rs->Typespecs());
    vecCells("SCOPES", ls->Scopes(), rs->Scopes());
    vecCells("LET_DECLS", ls->Let_decls(), rs->Let_decls());
    const instance* li = any_cast<const instance*>(L);
    const instance* ri = any_cast<const instance*>(R);
    if (li && ri) {
        vecCells("CLASS_DEFNS", li->Class_defns(), ri->Class_defns());
        vecCells("TASK_FUNCS", li->Task_funcs(), ri->Task_funcs());
        vecCells("NETS", li->Nets(), ri->Nets());
    }
    return 0;
}

int main(int argc, char** argv) {
    if (argc < 4) {
        fprintf(stderr, "usage: ct210sub <golden> <ours> <what>\n");
        return 2;
    }
    Serializer sg, so;
    if (sg.Restore(std::string(argv[1])).empty()) { printf("RESTORE_FAIL golden\n"); return 1; }
    if (so.Restore(std::string(argv[2])).empty()) { printf("RESTORE_FAIL ours\n"); return 1; }
    const design* dg = theDesign(sg);
    const design* dou = theDesign(so);
    if (!dg || !dou) { printf("NO_DESIGN\n"); return 1; }
    const BaseClass* L = pick(dg, argv[3]);
    const BaseClass* R = pick(dou, argv[3]);
    if (!L || !R) { printf("NOT_FOUND %s L=%p R=%p\n", argv[3], (void*)L, (void*)R); return 1; }
    if (argc >= 5 && std::string(argv[4]) == "cells") return cells(L, R);
    CompareContext ctx;
    int32_t r = L->Compare(R, &ctx);
    printf("SUB %s r=%d\n", argv[3], (int)r);
    printf("  LHSPTR %p type=%d\n", (const void*)ctx.m_failedLhs,
           ctx.m_failedLhs ? (int)ctx.m_failedLhs->UhdmType() : -1);
    printf("  RHSPTR %p type=%d\n", (const void*)ctx.m_failedRhs,
           ctx.m_failedRhs ? (int)ctx.m_failedRhs->UhdmType() : -1);
    printf("  LHS %s\n", face(ctx.m_failedLhs).c_str());
    printf("  RHS %s\n", face(ctx.m_failedRhs).c_str());
    if (ctx.m_failedLhs) printf("  LHSPAR %s\n", face(ctx.m_failedLhs->VpiParent()).c_str());
    if (ctx.m_failedRhs) printf("  RHSPAR %s\n", face(ctx.m_failedRhs->VpiParent()).c_str());
    return 0;
}
