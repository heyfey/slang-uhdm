// r10uvm213 — THE PER-VIEW PLACEHOLDER READER.  MEASUREMENT ONLY; the official
// `~/git-repos/UHDM/build/bin/uhdm-cmp` is the sole acceptance judge.
// LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
//
// WHY IT EXISTS.  r10uvm210 proved the SeqDriver head is a DEF/ELAB VIEW
// CROSSING: `typespec::Compare` (generated typespec.cpp:94) reads `Instance()`,
// so a def-view class-body placeholder whose back-pointer names the ELABORATED
// package drags the judge from golden's DEF package listing into our ELABORATED
// one.  `ct210inst --tsinst` prints one line per typespec with an Instance and
// no holder at all, so it can say WHICH VIEW is named but not WHO holds the
// copy, and it cannot say whether a copy is SHARED.  This one answers both.
//
//   --copies <db> [namere]   one block per placeholder OBJECT: its key
//                            (`kind|name|line:col`), its `Instance` VIEW, and
//                            every ref_typespec that points at it with the
//                            ancestor chain of that reference (the HOLDER).
//                            A block with NREFS>1 is a SHARED copy.
//   --keycount <db> [namere] the same, aggregated: one line per
//                            (key, instance-view, holder-listing) with a count.
//                            This is the census row form.
//   --arity <db> [namere]    one line per key: how many COPIES exist and how
//                            many name each view.  The ARITY question.
//   --holders <db> <id>      the holder chain of one object id.
//
// The HOLDER LISTING is the outermost named ancestor of the reference — a
// package (labelled ALLPKG / TOPPKG from design->AllPackages/TopPackages, the
// same labels ct210inst uses), a module, or a class_defn — plus the subroutine
// the reference sits in.  Nothing here reads VpiFullName (the dump SYNTHESIZES
// it from the parent chain) and nothing here mints.
//
// build: g++ -O2 -std=c++17 ct213ts.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct213ts
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <map>
#include <regex>
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

static std::string viewOf(const BaseClass* o) {
    if (!o) return "NONE";
    auto it = gView.find(o);
    return (it == gView.end() ? std::string("-") : it->second) + ":" +
           std::string(o->VpiName());
}

static std::string kindName(const BaseClass* o) {
    return std::string(UhdmName(o->UhdmType()));
}

// The ancestor chain of a reference, OUTERMOST FIRST, as `kind:name` steps.
// The outermost step carries its view label so a def-view holder and an
// elaborated holder of the same package never collapse into one key.
static std::string holderChain(const BaseClass* o) {
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

int main(int argc, char** argv) {
    if (argc < 3) {
        fprintf(stderr,
                "usage: ct213ts --copies   <db> [name-regex]\n"
                "       ct213ts --keycount <db> [name-regex]\n"
                "       ct213ts --arity    <db> [name-regex]\n"
                "       ct213ts --holders  <db> <uhdmId>\n");
        return 2;
    }
    std::string mode = argv[1];
    Serializer s;
    if (s.Restore(std::string(argv[2])).empty()) {
        printf("RESTORE_FAIL %s\n", argv[2]);
        return 1;
    }
    markViews(s);

    if (mode == "--holders") {
        unsigned want = argc >= 4 ? (unsigned)strtoul(argv[3], nullptr, 10) : 0u;
        for (auto& kv : s.AllObjects()) {
            const BaseClass* o = kv.first;
            if (!o || (unsigned)o->UhdmId() != want) continue;
            printf("OBJ %s '%s' id=%u @%u:%u\n  CHAIN %s\n",
                   kindName(o).c_str(), std::string(o->VpiName()).c_str(),
                   (unsigned)o->UhdmId(), o->VpiLineNo(),
                   (unsigned)o->VpiColumnNo(), holderChain(o).c_str());
        }
        return 0;
    }

    std::regex re(argc >= 4 ? argv[3] : ".*");
    // ref_typespec -> its Actual_typespec, indexed the other way round.
    std::map<const typespec*, std::vector<const ref_typespec*>> refs;
    for (auto& kv : s.AllObjects()) {
        const BaseClass* o = kv.first;
        if (!o) continue;
        const ref_typespec* rt = any_cast<const ref_typespec*>(o);
        if (!rt) continue;
        if (const typespec* at = rt->Actual_typespec()) refs[at].push_back(rt);
    }

    // key -> instview -> holder -> count ; and key -> copies
    std::map<std::string, std::map<std::string, std::map<std::string, long>>> agg;
    std::map<std::string, std::map<std::string, long>> arity;  // key -> view -> copies

    for (auto& kv : s.AllObjects()) {
        const BaseClass* o = kv.first;
        if (!o) continue;
        const typespec* t = any_cast<const typespec*>(o);
        if (!t) continue;
        std::string nm(t->VpiName());
        if (nm.empty()) continue;
        if (!std::regex_search(nm, re)) continue;
        char kb[512];
        snprintf(kb, sizeof kb, "%s|%s|%u:%u", kindName(t).c_str(), nm.c_str(),
                 t->VpiLineNo(), (unsigned)t->VpiColumnNo());
        std::string key = kb;
        std::string iv = viewOf((const BaseClass*)t->Instance());
        arity[key][iv]++;
        auto it = refs.find(t);
        if (it == refs.end()) {
            agg[key][iv]["<unreferenced>"]++;
            if (mode == "--copies")
                printf("TS %s id=%u INST=%s NREFS=0\n", key.c_str(),
                       (unsigned)t->UhdmId(), iv.c_str());
            continue;
        }
        if (mode == "--copies")
            printf("TS %s id=%u INST=%s NREFS=%zu\n", key.c_str(),
                   (unsigned)t->UhdmId(), iv.c_str(), it->second.size());
        for (auto* rt : it->second) {
            std::string hc = holderChain((const BaseClass*)rt->VpiParent());
            agg[key][iv][hc]++;
            if (mode == "--copies") printf("  REF %s\n", hc.c_str());
        }
    }

    if (mode == "--keycount") {
        for (auto& [k, m1] : agg)
            for (auto& [v, m2] : m1)
                for (auto& [h, c] : m2)
                    printf("KC\t%s\t%s\t%s\t%ld\n", k.c_str(), v.c_str(),
                           h.c_str(), c);
        return 0;
    }
    if (mode == "--arity") {
        for (auto& [k, m1] : arity) {
            long tot = 0;
            std::string vs;
            for (auto& [v, c] : m1) {
                tot += c;
                if (!vs.empty()) vs += " ";
                vs += v + "=" + std::to_string(c);
            }
            printf("AR\t%s\tCOPIES=%ld\t%s\n", k.c_str(), tot, vs.c_str());
        }
        return 0;
    }
    if (mode != "--copies") {
        fprintf(stderr, "unknown mode %s\n", mode.c_str());
        return 2;
    }
    return 0;
}
