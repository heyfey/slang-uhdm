// r10uvm28a — package-listing localizer, ASYMMETRY-AWARE.
//
// r10uvm27l printed `d1(ctx.m_failedLhs ? ctx.m_failedLhs : a)`, which HIDES
// the single most informative distinction UHDM's CompareContext carries:
// `SafeCompare` sets BOTH m_failedLhs and m_failedRhs on a scalar/size
// mismatch, but only ONE of them when a scalar POINTER is null on one side
// (BaseClass.h:187-199).  A row printed as "L <the element itself>  R <deep
// object>" is therefore not a pair at all — it is "golden had nullptr here and
// we have this object", and the L column is noise.
//
// This probe prints `<null>` explicitly for the unset side and, for the set
// side, the vpiParent chain, so the OWNER of the extra/missing pointer is
// named instead of guessed.
//   r10uvm28a <golden.uhdm> <ours.uhdm> [pkgFilter]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <map>
#include <string>
#include <vector>
using namespace UHDM;

static std::vector<const BaseClass*> g_cut;

static std::string d1(const BaseClass* o) {
    if (!o) return "<null>";
    return std::string(UhdmName(o->UhdmType())) + " '" + std::string(o->VpiName()) +
           "' " + std::to_string(o->VpiLineNo()) + ":" +
           std::to_string(o->VpiColumnNo());
}

static std::string chain(const BaseClass* o) {
    if (!o) return "";
    std::string r;
    const BaseClass* p = o->VpiParent();
    for (int i = 0; p && i < 6; ++i) {
        r += " <- " + d1(p);
        p = p->VpiParent();
    }
    return r;
}

static void cmp1(const std::string& tag, const BaseClass* a, const BaseClass* b) {
    if (!a && !b) return;
    if (!a || !b) {
        std::cout << tag << "\n    L " << d1(a) << "\n    R " << d1(b) << "\n";
        return;
    }
    CompareContext ctx;
    for (auto* c : g_cut) ctx.m_visited.insert(c);
    if (a->Compare(b, &ctx) == 0) return;
    std::cout << tag << "\n    L " << d1(ctx.m_failedLhs) << chain(ctx.m_failedLhs)
              << "\n    R " << d1(ctx.m_failedRhs) << chain(ctx.m_failedRhs) << "\n";
}

template <typename V>
static void vec(const std::string& tag, const V* ga, const V* gb) {
    size_t na = ga ? ga->size() : 0, nb = gb ? gb->size() : 0;
    if (na != nb) std::cout << tag << " SIZE " << na << " vs " << nb << "\n";
    for (size_t i = 0; i < na && i < nb; ++i)
        cmp1(tag + "[" + std::to_string(i) + "] " +
                 std::string((*ga)[i] ? (*ga)[i]->VpiName() : ""),
             (*ga)[i], (*gb)[i]);
}

static void doPkgs(const char* view, const std::vector<package*>* a,
                   const std::vector<package*>* b, const std::string& filt) {
    if (!a || !b) return;
    std::map<std::string, const package*> mb;
    for (auto* p : *b) mb[std::string(p->VpiName())] = p;
    for (auto* p : *a) {
        std::string nm(p->VpiName());
        if (!filt.empty() && nm.find(filt) == std::string::npos) continue;
        auto it = mb.find(nm);
        if (it == mb.end()) {
            std::cout << view << " " << nm << " MISSING\n";
            continue;
        }
        const package* q = it->second;
        std::string t = std::string(view) + " " + nm + " ";
        vec(t + "var", p->Variables(), q->Variables());
        vec(t + "cls", p->Class_defns(), q->Class_defns());
        vec(t + "tf", p->Task_funcs(), q->Task_funcs());
        vec(t + "ts", p->Typespecs(), q->Typespecs());
        vec(t + "par", p->Parameters(), q->Parameters());
        vec(t + "pa", p->Param_assigns(), q->Param_assigns());
    }
}

int main(int argc, char** argv) {
    Serializer sa, sb;
    auto ha = sa.Restore(std::filesystem::path(argv[1]));
    auto hb = sb.Restore(std::filesystem::path(argv[2]));
    const design* da = (const design*)((uhdm_handle*)ha[0])->object;
    const design* db = (const design*)((uhdm_handle*)hb[0])->object;
    std::string filt = argc > 3 ? argv[3] : "";
    auto seed = [&](const design* d) {
        g_cut.push_back(d);
        for (auto* v : {d->AllPackages(), d->TopPackages()})
            if (v)
                for (auto* p : *v) g_cut.push_back(p);
        for (auto* v : {d->AllModules(), d->TopModules()})
            if (v)
                for (auto* p : *v) g_cut.push_back(p);
    };
    seed(da);
    seed(db);
    doPkgs("DEFPKG", da->AllPackages(), db->AllPackages(), filt);
    doPkgs("ELABPKG", da->TopPackages(), db->TopPackages(), filt);
    return 0;
}
