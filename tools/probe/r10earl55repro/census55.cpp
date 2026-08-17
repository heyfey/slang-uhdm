// r10earl55 — THE PARAM-ASSIGN TYPESPEC CENSUS.
//
// MEASUREMENT-ONLY.  uhdm-cmp remains the sole acceptance judge.
//
// The head of this pass is a LOC-LESS typespec KIND disagreement under an
// ELABORATED `param_assign`'s folded Rhs constant:
//
//   param_assign(rv_dm.sv:50:34)  Rhs = constant BIN:1 sz1
//     |vpiTypespec ref_typespec{<instance path>}
//        |vpiActual  golden: int_typespec (LOC-LESS, VpiValue "UINT:1")
//                    ours  : logic_typespec (LOC-LESS, range [0:0])
//
// uhdm-cmp stops at the first such object, so the only way to know whether a
// law is worth one cell or a thousand is to count them ALL, on BOTH sides,
// keyed on something that survives renumbering.  Key = (Lhs VpiFullName,
// param_assign span, view).  The VIEW is part of the key on purpose: the DEF
// listing (`design::AllModules`) and the ELAB listing (`design::TopModules`)
// contain param_assigns at the SAME span with the SAME parameter name, and
// merging them silently halves the census (and hides the earl38 DEF fence).
//
// Every index is built in UhdmId order, never `AllObjects()` address order.
//
// build:
//   g++ -O2 -std=c++17 census55.cpp -I ~/.local/include \
//       -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o census55
// usage: census55 <golden.uhdm> <ours.uhdm> [--all] [--selftest]
//   default output: the family histogram + the disagreeing cells.
//   --all: every cell, agreeing or not.
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <algorithm>
#include <cstdio>
#include <cstring>
#include <map>
#include <set>
#include <string>
#include <unordered_map>
#include <unordered_set>
#include <variant>
#include <vector>

using namespace UHDM;

static std::string base(std::string_view p) {
    size_t i = p.find_last_of('/');
    return std::string(i == std::string_view::npos ? p : p.substr(i + 1));
}
// SPAN WITHOUT THE FILE, deliberately, and this is a MEASURED correction, not
// a convenience: our `param_assign` objects carry an EMPTY VpiFile where
// golden's carry the path, so a file-keyed census reported 13 190 golden cells
// and 13 174 of ours as ALL UNPAIRED — a total instrument failure that reads
// exactly like "nothing to compare".  `param_assign::Compare` does not read
// VpiFile, so line:col is the honest key; `fileOf` keeps the file printable.
static std::string spanOf(const BaseClass* o) {
    if (!o) return "<null>";
    char b[192];
    snprintf(b, sizeof b, "%u:%u-%u:%u", o->VpiLineNo(), (unsigned)o->VpiColumnNo(),
             o->VpiEndLineNo(), (unsigned)o->VpiEndColumnNo());
    return b;
}
static std::string fileOf(const BaseClass* o) {
    return o ? base(o->VpiFile()) : "";
}
static std::string fullName(const BaseClass* o) {
    if (!o) return "";
    auto pv = o->GetVpiPropertyValue(vpiFullName);
    if (std::holds_alternative<const char*>(pv)) {
        const char* p = std::get<const char*>(pv);
        if (p && *p) return p;
    }
    return std::string(o->VpiName());
}
// int_typespec is the ONLY typespec kind that carries a VpiValue, and golden's
// head object carries "UINT:1" in it — so the value is read through the kind,
// not through a generic property selector (there is none for it).
static std::string valOf(const BaseClass* o) {
    if (!o) return "";
    if (auto* it = any_cast<const int_typespec*>((const any*)o))
        return std::string(it->VpiValue());
    return "";
}
static bool locless(const BaseClass* o) {
    return o && o->VpiLineNo() == 0 && o->VpiColumnNo() == 0;
}

// The DESCRIPTOR of a param_assign Rhs's typespec: what the fix has to
// reproduce.  Kept coarse on purpose (kind + loc-less/span + value shape) so
// that the family histogram groups by SHAPE and not by instance name.
static std::string tsDesc(const any* rhs) {
    if (!rhs) return "NO-RHS";
    const ref_typespec* rt = nullptr;
    if (auto* e = any_cast<const expr*>(rhs)) rt = e->Typespec();
    if (!rt) return "NO-TS";
    const typespec* a = rt->Actual_typespec();
    if (!a) return "TS-NULL-ACTUAL";
    std::string d = UhdmName(a->UhdmType());
    d += locless(a) ? "@LOCLESS" : "@LOC";
    if (!a->VpiName().empty()) d += "(named)";
    std::string v = valOf(a);
    if (!v.empty()) {
        // value SHAPE, not the value: digits fold so the family survives
        std::string f;
        bool ind = false;
        for (char c : v) {
            if (isdigit((unsigned char)c)) { if (!ind) f += '#'; ind = true; }
            else { ind = false; f += c; }
        }
        d += "[val " + f + "]";
    }
    if (getenv("CENSUS55_EXACT") && !v.empty()) d += "{=" + v + "}";
    if (auto* lt = any_cast<const logic_typespec*>((const any*)a))
        if (lt->Ranges() && !lt->Ranges()->empty()) d += "{ranged}";
    if (auto* it = any_cast<const int_typespec*>((const any*)a))
        if (it->Ranges() && !it->Ranges()->empty()) d += "{ranged}";
    return d;
}
static std::string rhsKind(const any* rhs) {
    return rhs ? std::string(UhdmName(rhs->UhdmType())) : "<null>";
}

struct Cell {
    std::string rhs, ts, tsspan, file;
};

static void collect(Serializer& s, std::map<std::string, Cell>& out, bool& ok) {
    std::vector<const BaseClass*> all;
    for (const auto& [obj, id] : s.AllObjects())
        if (obj) all.push_back(obj);
    std::sort(all.begin(), all.end(), [](const BaseClass* a, const BaseClass* b) {
        return a->UhdmId() != b->UhdmId() ? a->UhdmId() < b->UhdmId() : a < b;
    });
    // VIEW membership: the outermost module_inst ancestor, looked up in the
    // design's two lists.  Never guessed from a name.
    const design* dz = nullptr;
    for (const BaseClass* o : all)
        if (o->UhdmType() == uhdmdesign) { dz = (const design*)o; break; }
    if (!dz) { ok = false; return; }
    std::unordered_set<const BaseClass*> defRoots, elabRoots;
    if (dz->AllModules()) for (auto* m : *dz->AllModules()) defRoots.insert(m);
    if (dz->TopModules()) for (auto* m : *dz->TopModules()) elabRoots.insert(m);
    for (const BaseClass* o : all) {
        if (o->UhdmType() != uhdmparam_assign) continue;
        auto* pa = (const param_assign*)o;
        const BaseClass* top = o;
        while (top->VpiParent() && top->VpiParent()->UhdmType() != uhdmdesign)
            top = top->VpiParent();
        const char* view = defRoots.count(top) ? "DEF"
                         : elabRoots.count(top) ? "ELAB" : "OTHER";
        std::string key = std::string(view) + "|" + fullName(pa->Lhs()) + "|" + spanOf(pa);
        std::string f = fileOf(pa);
        if (f.empty() && pa->Lhs()) f = fileOf(pa->Lhs());
        Cell c;
        c.rhs = rhsKind(pa->Rhs());
        c.ts = tsDesc(pa->Rhs());
        const ref_typespec* rt = nullptr;
        if (auto* e = any_cast<const expr*>(pa->Rhs())) rt = e->Typespec();
        c.tsspan = rt && rt->Actual_typespec()
                       ? fileOf(rt->Actual_typespec()) + ":" + spanOf(rt->Actual_typespec())
                       : "-";
        c.file = f;
        // a duplicate key is REPORTED, never overwritten in silence
        auto it = out.find(key);
        if (it != out.end() && (it->second.rhs != c.rhs || it->second.ts != c.ts))
            printf("DUPKEY %s  %s/%s vs %s/%s\n", key.c_str(), it->second.rhs.c_str(),
                   it->second.ts.c_str(), c.rhs.c_str(), c.ts.c_str());
        out[key] = c;
    }
    ok = true;
}

int main(int argc, char** argv) {
    if (argc < 3) {
        fprintf(stderr, "usage: census55 <golden.uhdm> <ours.uhdm> [--all]\n");
        return 2;
    }
    bool all = false;
    for (int i = 3; i < argc; i++) if (!strcmp(argv[i], "--all")) all = true;
    Serializer sg, so;
    if (sg.Restore(std::string(argv[1])).empty()) { fprintf(stderr, "RESTORE_FAILED %s\n", argv[1]); return 3; }
    if (so.Restore(std::string(argv[2])).empty()) { fprintf(stderr, "RESTORE_FAILED %s\n", argv[2]); return 3; }
    std::map<std::string, Cell> G, O;
    bool okg = false, oko = false;
    collect(sg, G, okg);
    collect(so, O, oko);
    if (!okg || !oko) { fprintf(stderr, "NO_DESIGN\n"); return 4; }
    printf("# census55 golden_cells=%zu ours_cells=%zu\n", G.size(), O.size());
    std::map<std::string, int> fam, viewfam;
    int agree = 0, dis = 0, unpairedG = 0, unpairedO = 0;
    for (auto& [k, g] : G) {
        auto it = O.find(k);
        if (it == O.end()) { unpairedG++; printf("UNPAIRED-GOLDEN %s  %s / %s\n", k.c_str(), g.rhs.c_str(), g.ts.c_str()); continue; }
        const Cell& o = it->second;
        std::string view = k.substr(0, k.find('|'));
        if (g.rhs == o.rhs && g.ts == o.ts) {
            agree++;
            if (all) printf("AGREE  %s  %s / %s\n", k.c_str(), g.rhs.c_str(), g.ts.c_str());
            continue;
        }
        dis++;
        std::string f = view + "  " + g.rhs + ">" + o.rhs + "  TS " + g.ts + " > " + o.ts;
        fam[f]++;
        printf("DISAGREE %s [%s]\n   G %s / %s @%s\n   O %s / %s @%s\n", k.c_str(),
               g.rhs.c_str(), g.ts.c_str(), g.tsspan.c_str(),
               o.rhs.c_str(), o.ts.c_str(), o.tsspan.c_str());
    }
    for (auto& [k, o] : O)
        if (!G.count(k)) { unpairedO++; printf("UNPAIRED-OURS %s  %s / %s\n", k.c_str(), o.rhs.c_str(), o.ts.c_str()); }
    printf("\n== SUMMARY  agree=%d disagree=%d unpaired_golden=%d unpaired_ours=%d\n",
           agree, dis, unpairedG, unpairedO);
    printf("== FAMILIES (view  rhs-kind  typespec-shape)\n");
    for (auto& [f, c] : fam) printf("  %6d  %s\n", c, f.c_str());
    return 0;
}
