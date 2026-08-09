// r10uvm27l — PACKAGE-LISTING localizer.  uhdm-cmp reports ONE first-failing
// pair for the whole design, so a fix that clears an early failure makes a
// later one look like a regression.  This compares each package's listings
// ELEMENT BY ELEMENT with a fresh CompareContext (packages/designs/modules
// cut-seeded so Instance() recursion is a no-op), and prints the first failing
// pair PER ELEMENT — the whole failing set at once, not just its head.
//   r10uvm27l <golden.uhdm> <ours.uhdm> [pkgFilter]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <map>
#include <string>
#include <vector>
using namespace UHDM;

static std::vector<const BaseClass*> g_cut;

static bool g_why = false;

static std::string d1(const BaseClass* o) {
    if (!o) return "<null>";
    std::string r = std::string(UhdmName(o->UhdmType())) + " '" +
                    std::string(o->VpiName()) + "' " +
                    std::to_string(o->VpiLineNo()) + ":" +
                    std::to_string(o->VpiColumnNo());
    if (!g_why) return r;
    // The scalar fields uhdm-cmp actually reads for the common kinds, so a
    // "same type, same name" pair can be told apart without a whole-db dump.
    if (auto* n = any_cast<const scope*>(o))
        r += " full='" + std::string(n->VpiFullName()) + "'";
    if (auto* v = any_cast<const variables*>(o))
        r += " auto=" + std::to_string((int)v->VpiAutomatic()) +
             " const=" + std::to_string((int)v->VpiConstantVariable()) +
             " vis=" + std::to_string(v->VpiVisibility()) +
             " sgn=" + std::to_string((int)v->VpiSigned()) +
             " sz=" + std::to_string(v->VpiSize()) +
             " ts=" + (v->Typespec() && v->Typespec()->Actual_typespec()
                           ? std::string(UhdmName(v->Typespec()
                                                      ->Actual_typespec()
                                                      ->UhdmType()))
                           : "-") +
             " expr=" + (v->Expr() ? std::string(UhdmName(v->Expr()->UhdmType()))
                                   : "-");
    if (auto* c = any_cast<const constant*>(o))
        r += " ct=" + std::to_string(c->VpiConstType()) +
             " dec='" + std::string(c->VpiDecompile()) + "'" +
             " sz=" + std::to_string(c->VpiSize());
    if (auto* t = any_cast<const typespec*>(o))
        r += " inst=" +
             (t->Instance() ? std::string(t->Instance()->VpiName()) : "-");
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
    std::cout << tag << "\n    L " << d1(ctx.m_failedLhs ? ctx.m_failedLhs : a)
              << "\n    R " << d1(ctx.m_failedRhs ? ctx.m_failedRhs : b) << "\n";
}

template <typename V>
static void vec(const std::string& tag, const V* ga, const V* gb) {
    size_t na = ga ? ga->size() : 0, nb = gb ? gb->size() : 0;
    if (na != nb)
        std::cout << tag << " SIZE " << na << " vs " << nb << "\n";
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
    if (filt == "--why") {
        g_why = true;
        filt = argc > 4 ? argv[4] : "";
    }
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
