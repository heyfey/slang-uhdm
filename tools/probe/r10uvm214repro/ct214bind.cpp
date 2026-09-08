// r10uvm214 — THE PACKAGE-PARAMETER BINDING READER.  MEASUREMENT ONLY; the
// official `~/git-repos/UHDM/build/bin/uhdm-cmp` is the sole acceptance judge.
// LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
//
// WHY IT EXISTS.  r10uvm213's R0 named the SeqDriver/MiniAmiq head a BINDING:
// `ref_obj::Compare` (build/generated/src/ref_obj.cpp) reads `Actual_group`, and
// in the home package's DEF listing of an out-of-body class method golden binds
// a package-parameter reference to THAT LISTING's own `param_assign` Rhs while
// we bind the shared ELABORATED one (a folded constant).  Nothing in
// r10uvm210/213's instruments reads `Actual_group`, so this one does.
//
//   --refs  <db> [namere]  one line per package-parameter REFERENCE: its key,
//                          what it is bound to (kind, span, and THE LISTING
//                          VIEW THE BOUND OBJECT LIVES IN), and its holder
//                          chain.  The identity payload is what makes a
//                          def/elab crossing visible: two constants of equal
//                          value are Compare-equal but live in different
//                          listings.
//   --keycount <db> [re]   the same aggregated to census rows
//                          (`KC<TAB>key<TAB>payload<TAB>holder<TAB>count`),
//                          the row form cen214.py joins as a MULTISET.
//   --pop   <db> [namere]  THE POPULATION TABLE: (listing view class) x
//                          (referent kind), counts.
//   --parhs <db>           one line per `param_assign`: the LISTING it is in,
//                          the parameter NAME, and its Rhs with the same
//                          payload `--keycount` prints for a bound reference.
//                          This is what a def-view listing's own reference must
//                          land on, so predict214.py can name the POST-PATCH
//                          payload of every cell BEFORE the patch exists.
//   --one   <db> <id>      one object: kind, span, chain, and — for a ref_obj —
//                          its Actual with the same detail.
//
// A "package-parameter reference" is a `ref_obj` whose bare name (the text
// after the last `::`) is the Lhs name of some `param_assign` in the database.
// The test is by NAME on purpose: it catches the reference on BOTH sides
// whatever it is bound to, including `<null>`, which an Actual-keyed test would
// silently drop on exactly the side that is wrong.
//
// Nothing here mints (never `getDefaultSpecialization`), nothing reads
// VpiFullName (the dump SYNTHESIZES it from the parent chain), and no count
// here is an acceptance verdict.
//
// build: g++ -O2 -std=c++17 ct214bind.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct214bind
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <map>
#include <regex>
#include <set>
#include <string>
#include <vector>

using namespace UHDM;

static std::map<const BaseClass*, std::string> gView;

static void markViews(Serializer& s) {
    for (auto& kv : s.AllObjects()) {
        const BaseClass* o = kv.first;
        if (!o || o->UhdmType() != uhdmdesign) continue;
        const design* d = (const design*)o;
        if (d->AllPackages())
            for (auto* x : *d->AllPackages()) gView[x] = "ALLPKG";
        if (d->TopPackages())
            for (auto* x : *d->TopPackages())
                gView[x] = gView.count(x) ? "BOTHPKG" : "TOPPKG";
        if (d->AllModules())
            for (auto* x : *d->AllModules()) gView[x] = "ALLMOD";
        if (d->TopModules())
            for (auto* x : *d->TopModules())
                gView[x] = gView.count(x) ? "BOTHMOD" : "TOPMOD";
    }
}

static std::string kindName(const BaseClass* o) {
    return std::string(UhdmName(o->UhdmType()));
}

static std::string viewOf(const BaseClass* o) {
    if (!o) return "NONE";
    auto it = gView.find(o);
    return (it == gView.end() ? std::string("-") : it->second) + ":" +
           std::string(o->VpiName());
}

// The ancestor chain, OUTERMOST FIRST, as `kind:name` steps; the outermost
// step carries its view label so the two listings of one package never
// collapse into one key.
static std::string chainOf(const BaseClass* o) {
    std::vector<const BaseClass*> up;
    for (int d = 0; o && d < 200; ++d, o = (const BaseClass*)o->VpiParent())
        up.push_back(o);
    std::string out;
    for (size_t i = up.size(); i-- > 0;) {
        const BaseClass* x = up[i];
        if (x->UhdmType() == uhdmdesign) continue;
        if (!out.empty()) out += "<";
        if (i + 1 == up.size() || up[i + 1]->UhdmType() == uhdmdesign)
            out += kindName(x) + "[" + viewOf(x) + "]";
        else
            out += kindName(x) + ":" + std::string(x->VpiName());
    }
    return out.empty() ? std::string("<root>") : out;
}

// The OUTERMOST holder label of an object — `ALLPKG:uvm_pkg`, `TOPPKG:uvm_pkg`,
// `-:<class>`, … — which is the listing the object lives in.  A def-view Rhs
// and its elaborated twin differ here and NOWHERE ELSE when their values agree,
// so this is what makes the crossing measurable.
static std::string listingOf(const BaseClass* o) {
    const BaseClass* last = nullptr;
    for (int d = 0; o && d < 200; ++d, o = (const BaseClass*)o->VpiParent()) {
        if (o->UhdmType() == uhdmdesign) break;
        last = o;
    }
    if (!last) return "NOLIST";
    return kindName(last) + "[" + viewOf(last) + "]";
}

static std::string bare(const std::string& n) {
    auto p = n.rfind("::");
    return p == std::string::npos ? n : n.substr(p + 2);
}

// What the judge and the bytes both see about the bound object: its KIND, its
// SPAN, the LISTING it lives in, and a kind-specific discriminator.
static std::string actDesc(const BaseClass* a) {
    if (!a) return "ACT=<null>";
    char b[1024];
    std::string extra;
    switch (a->UhdmType()) {
        case uhdmconstant: {
            const constant* c = (const constant*)a;
            extra = "v=" + std::string(c->VpiValue()) + ",d=" +
                    std::string(c->VpiDecompile()) + ",sz=" +
                    std::to_string(c->VpiSize());
            break;
        }
        case uhdmoperation: {
            const operation* op = (const operation*)a;
            extra = "op=" + std::to_string(op->VpiOpType());
            break;
        }
        default:
            extra = "n=" + std::string(a->VpiName());
            break;
    }
    snprintf(b, sizeof b, "ACT=%s@%u:%u[%s]{%s}", kindName(a).c_str(),
             a->VpiLineNo(), (unsigned)a->VpiColumnNo(),
             listingOf(a).c_str(), extra.c_str());
    return b;
}

int main(int argc, char** argv) {
    if (argc < 3) {
        fprintf(stderr,
                "usage: ct214bind --refs     <db> [name-regex]\n"
                "       ct214bind --parhs    <db>\n"
                "       ct214bind --keycount <db> [name-regex]\n"
                "       ct214bind --pop      <db> [name-regex]\n"
                "       ct214bind --one      <db> <uhdmId>\n");
        return 2;
    }
    std::string mode = argv[1];
    Serializer s;
    if (s.Restore(std::string(argv[2])).empty()) {
        printf("RESTORE_FAIL %s\n", argv[2]);
        return 1;
    }
    markViews(s);

    if (mode == "--one") {
        unsigned want = argc >= 4 ? (unsigned)strtoul(argv[3], nullptr, 10) : 0u;
        for (auto& kv : s.AllObjects()) {
            const BaseClass* o = kv.first;
            if (!o || (unsigned)o->UhdmId() != want) continue;
            printf("OBJ %s '%s' id=%u @%u:%u\n  CHAIN %s\n", kindName(o).c_str(),
                   std::string(o->VpiName()).c_str(), (unsigned)o->UhdmId(),
                   o->VpiLineNo(), (unsigned)o->VpiColumnNo(),
                   chainOf(o).c_str());
            if (const ref_obj* r = any_cast<const ref_obj*>(o)) {
                const BaseClass* a = (const BaseClass*)r->Actual_group();
                printf("  %s id=%u\n", actDesc(a).c_str(),
                       a ? (unsigned)a->UhdmId() : 0u);
                if (a) printf("  ACTCHAIN %s\n", chainOf(a).c_str());
            }
        }
        return 0;
    }

    // Every parameter NAME the database declares through a param_assign.
    std::set<std::string> pnames;
    for (auto& kv : s.AllObjects()) {
        const BaseClass* o = kv.first;
        if (!o || o->UhdmType() != uhdmparam_assign) continue;
        const param_assign* pa = (const param_assign*)o;
        if (pa->Lhs()) pnames.insert(bare(std::string(pa->Lhs()->VpiName())));
    }

    if (mode == "--parhs") {
        for (auto& kv : s.AllObjects()) {
            const BaseClass* o = kv.first;
            if (!o || o->UhdmType() != uhdmparam_assign) continue;
            const param_assign* pa = (const param_assign*)o;
            if (!pa->Lhs()) continue;
            printf("PA\t%s\t%s\t%s\n", listingOf(o).c_str(),
                   bare(std::string(pa->Lhs()->VpiName())).c_str(),
                   actDesc((const BaseClass*)pa->Rhs()).c_str());
        }
        return 0;
    }

    std::regex re(argc >= 4 ? argv[3] : ".*");
    std::map<std::string, std::map<std::string, std::map<std::string, long>>> agg;
    std::map<std::string, std::map<std::string, long>> pop;

    for (auto& kv : s.AllObjects()) {
        const BaseClass* o = kv.first;
        if (!o || o->UhdmType() != uhdmref_obj) continue;
        const ref_obj* r = (const ref_obj*)o;
        std::string nm(r->VpiName());
        if (nm.empty()) continue;
        std::string bn = bare(nm);
        if (!pnames.count(bn)) continue;
        if (!std::regex_search(nm, re)) continue;
        char kb[1024];
        snprintf(kb, sizeof kb, "ref|%s|%u:%u", nm.c_str(), r->VpiLineNo(),
                 (unsigned)r->VpiColumnNo());
        std::string key = kb;
        const BaseClass* a = (const BaseClass*)r->Actual_group();
        std::string pay = actDesc(a);
        std::string hc = chainOf((const BaseClass*)r->VpiParent());
        agg[key][pay][hc]++;
        // The population table: the LISTING the reference sits in x the KIND
        // of what it is bound to.
        pop[listingOf(o)][a ? kindName(a) : std::string("<null>")]++;
        if (mode == "--refs")
            printf("REF\t%s\t%s\t%s\n", key.c_str(), pay.c_str(), hc.c_str());
    }

    if (mode == "--keycount") {
        for (auto& [k, m1] : agg)
            for (auto& [p, m2] : m1)
                for (auto& [h, c] : m2)
                    printf("KC\t%s\t%s\t%s\t%ld\n", k.c_str(), p.c_str(),
                           h.c_str(), c);
        return 0;
    }
    if (mode == "--pop") {
        for (auto& [l, m1] : pop) {
            long tot = 0;
            std::string vs;
            for (auto& [k2, c] : m1) {
                tot += c;
                if (!vs.empty()) vs += " ";
                vs += k2 + "=" + std::to_string(c);
            }
            printf("POP\t%s\tREFS=%ld\t%s\n", l.c_str(), tot, vs.c_str());
        }
        return 0;
    }
    if (mode != "--refs") {
        fprintf(stderr, "unknown mode %s\n", mode.c_str());
        return 2;
    }
    return 0;
}
