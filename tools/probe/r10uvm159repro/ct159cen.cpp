// r10uvm159 — CONSTANT-TYPESPEC CENSUS.  MEASUREMENT ONLY: the official
// ~/git-repos/UHDM/build/bin/uhdm-cmp is the sole judge; this tool only reads
// databases and reports.  LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
//
// `constant` reaches the judge through (BaseClass) VpiType/VpiName/VpiDefName,
// then (expr) VpiDecompile, VpiSize, Typespec, then VpiConstType — measured
// from ~/git-repos/UHDM/build/generated/src/{BaseClass,expr,constant}.cpp.
// So a constant's TYPESPEC EDGE is read BEFORE its const-type, and the value
// is not read at all.
//
// One line per constant:
//  K <file>:<l>:<c>-<el>:<ec> ct=<constType> size=<n> dec=<decompile>
//    val=<value> ts=<none|refname/actualkind(actualname)@file:l:c-el:ec>
//    own=<parentkind>(<name>)@<file:l:c> rel=<relation-int> home=<...>
//    chain=<kinds...>
//
// build: g++ -O2 -std=c++17 ct159cen.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct159cen
// usage: ct159cen <db.uhdm> [--tag=T] [--at=L[:C]] [--file=F] [--withts] [--id=N]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <map>
#include <string>
#include <vector>

using namespace UHDM;

static std::string base(std::string_view p) {
    size_t i = p.find_last_of('/');
    return std::string(i == std::string_view::npos ? p : p.substr(i + 1));
}
static std::string kindOf(const BaseClass* o) {
    return o ? std::string(UhdmName(o->UhdmType())) : std::string("-");
}
static std::string nm(const BaseClass* o) {
    if (!o) return "-";
    std::string n(o->VpiName());
    return n.empty() ? std::string("-") : n;
}
static const char* ctName(int32_t t) {
    switch (t) {
        case vpiIntConst: return "int";
        case vpiRealConst: return "real";
        case vpiBinaryConst: return "bin";
        case vpiDecConst: return "dec";
        case vpiHexConst: return "hex";
        case vpiOctConst: return "oct";
        case vpiStringConst: return "str";
        case vpiUIntConst: return "uint";
        case vpiTimeConst: return "time";
        case 10: return "unbounded";
        case 11: return "null";
        default: return "?";
    }
}
// HOME COMPONENT (same keying as r10uvm156's ct156cen).
static std::string homeOf(const BaseClass* o) {
    for (int i = 0; i < 64 && o; ++i) {
        switch (o->UhdmType()) {
            case uhdmpackage: {
                std::string n(o->VpiName());
                return n.empty() ? std::string("pkg#?") : ("pkg:" + n);
            }
            case uhdmclass_defn: {
                std::string n(o->VpiName());
                return n.empty() ? std::string("cls#?") : ("cls:" + n);
            }
            case uhdmmodule_inst:
            case uhdmprogram: {
                std::string n(o->VpiDefName());
                return n.empty() ? std::string("mod:-") : ("mod:" + n);
            }
            case uhdminterface_inst: return "iface";
            case uhdmdesign: return "TOP";
            default: break;
        }
        o = o->VpiParent();
    }
    return "TOP";
}
int main(int argc, char** argv) {
    if (argc < 2) { fprintf(stderr, "usage: ct159cen <db.uhdm> [--tag=T]\n"); return 2; }
    std::string tag = "DB", wantFile;
    unsigned atL = 0, atC = 0, wantId = 0; bool useAt = false, withTs = false;
    for (int a = 2; a < argc; a++) {
        if (!strncmp(argv[a], "--tag=", 6)) tag = argv[a] + 6;
        else if (!strncmp(argv[a], "--at=", 5)) { sscanf(argv[a] + 5, "%u:%u", &atL, &atC); useAt = true; }
        else if (!strncmp(argv[a], "--file=", 7)) wantFile = argv[a] + 7;
        else if (!strncmp(argv[a], "--id=", 5)) wantId = (unsigned)atoi(argv[a] + 5);
        else if (!strcmp(argv[a], "--withts")) withTs = true;
    }
    Serializer s;
    const std::vector<vpiHandle> h = s.Restore(std::string(argv[1]));
    if (h.empty()) { fprintf(stderr, "restore failed %s\n", argv[1]); return 3; }

    // Reverse index: child -> holders, over EVERY relation the object model
    // exposes.  GetByVpiType is a closed dispatch per kind; we sweep the whole
    // small-int relation space so a constant's OWNING FIELD is named, not guessed.
    struct Hold { const BaseClass* h; int t; bool vec; };
    std::map<const BaseClass*, std::vector<Hold>> rev;
    for (const auto& [obj, i] : s.AllObjects()) {
        if (!obj) continue;
        for (int t = 1; t < 1100; ++t) {
            auto [single, vt, vec] = obj->GetByVpiType(t);
            if (single) rev[single].push_back({obj, t, false});
            if (vec) for (auto* e : *vec) if (e) rev[e].push_back({obj, t, true});
        }
    }

    size_t total = 0, withT = 0;
    for (const auto& [obj, i] : s.AllObjects()) {
        if (!obj || obj->UhdmType() != uhdmconstant) continue;
        const constant* c = (const constant*)obj;
        total++;
        const ref_typespec* rt = c->Typespec();
        if (rt) withT++;
        if (useAt && (c->VpiLineNo() != atL || (atC && c->VpiColumnNo() != atC))) continue;
        if (wantId && c->UhdmId() != wantId) continue;
        if (!wantFile.empty() && base(c->VpiFile()).find(wantFile) == std::string::npos) continue;
        if (withTs && !rt) continue;

        std::string ts = "none";
        if (rt) {
            const typespec* act = rt->Actual_typespec();
            char b[600];
            snprintf(b, sizeof b, "%s/%s(%s)@%s:%u:%u-%u:%u",
                     nm(rt).c_str(), kindOf(act).c_str(), nm(act).c_str(),
                     act ? base(act->VpiFile()).c_str() : "-",
                     act ? act->VpiLineNo() : 0u, act ? (unsigned)act->VpiColumnNo() : 0u,
                     act ? act->VpiEndLineNo() : 0u, act ? (unsigned)act->VpiEndColumnNo() : 0u);
            ts = b;
        }
        // OWNER FIELD: the first non-parent holder relation.
        std::string owner = "-", rel = "-";
        auto it = rev.find(obj);
        if (it != rev.end()) {
            for (const Hold& hh : it->second) {
                if (hh.t == 81) continue;   // vpiParent: X's parent is us, not a hold
                char b[400];
                snprintf(b, sizeof b, "%s%d%s", rel == "-" ? "" : ",", hh.t, hh.vec ? "v" : "");
                if (rel == "-") rel = ""; rel += b;
                if (owner == "-") {
                    snprintf(b, sizeof b, "%s(%s)@%s:%u:%u", kindOf(hh.h).c_str(),
                             nm(hh.h).c_str(), base(hh.h->VpiFile()).c_str(),
                             hh.h->VpiLineNo(), (unsigned)hh.h->VpiColumnNo());
                    owner = b;
                }
            }
        }
        const BaseClass* p = c->VpiParent();
        std::string chain;
        for (const BaseClass* q = p; q && chain.size() < 240; q = q->VpiParent()) {
            chain += kindOf(q);
            std::string n = nm(q);
            if (n != "-") { chain += "("; chain += n; chain += ")"; }
            chain += "<";
        }
        std::string val(c->VpiValue());
        std::string dec(c->VpiDecompile());
        printf("%s K %s:%u:%u-%u:%u ct=%s size=%d dec=[%s] val=[%s] ts=%s "
               "par=%s(%s) own=%s rel=%s home=%s chain=%s id=%u\n",
               tag.c_str(), base(c->VpiFile()).c_str(), c->VpiLineNo(),
               (unsigned)c->VpiColumnNo(), c->VpiEndLineNo(), (unsigned)c->VpiEndColumnNo(),
               ctName(c->VpiConstType()), c->VpiSize(), dec.c_str(), val.c_str(),
               ts.c_str(), kindOf(p).c_str(), nm(p).c_str(), owner.c_str(), rel.c_str(),
               homeOf(p).c_str(), chain.c_str(), c->UhdmId());
    }
    printf("%s TOTAL constant=%zu withTypespec=%zu\n", tag.c_str(), total, withT);
    return 0;
}
