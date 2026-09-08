// r10v212 (VERIFIER) — THE FILLS LEDGER.  MEASUREMENT ONLY; the official
// `~/git-repos/UHDM/build/bin/uhdm-cmp` is the sole judge.
//
// LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
//
// The pass under verification only ever CLEARS a `class_typespec`'s
// `Parameters`/`Param_assigns`.  The regression it could cause is therefore
// exactly one shape: a listing GOLDEN HAS that OURS LOSES.  This tool pairs
// every `class_typespec` in a golden database with its counterpart in ours by
// FACE — (VpiName, owner kind:name, Class_defn name, is-it-a-clone) — as a
// MULTISET (a last-writer map silently drops rows; RESUME §9 census traps) and
// reports four counters:
//
//   FILL_LOST   golden's cell carries a listing, ours does not   <- THE GATE
//   FILL_EXTRA  ours carries one, golden's does not
//   FILL_SIZE   both carry one, different sizes
//   UNPAIRED_*  a face present on one side only (reported, never scored as a
//               fill verdict — an unpaired face is a different residue)
//
// `NUL` (a NULL vector pointer) and `n0` are folded together ON PURPOSE here:
// `BaseClass.h:217-222` guards both null-vs-non-null arms with `!empty()`, so
// the judge cannot tell a NULL vector from an empty one.  What it CAN tell is
// present-and-non-empty vs not, which is what this ledger scores.
//
// usage: ctv212fills <golden.uhdm> <ours.uhdm>
// build: g++ -O2 -std=c++17 ctv212fills.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ctv212fills
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <algorithm>
#include <cstdio>
#include <cstdlib>
#include <map>
#include <string>
#include <vector>

using namespace UHDM;

struct Cell {
    size_t params = 0;   // effective size: 0 for NULL or empty
    size_t pas = 0;
};

static size_t effSize(const std::vector<any*>* v) { return v ? v->size() : 0; }
static size_t effSizePa(const std::vector<param_assign*>* v) {
    return v ? v->size() : 0;
}

static std::string ownerOf(const BaseClass* o) {
    const BaseClass* p = o ? o->VpiParent() : nullptr;
    if (!p) return "<none>";
    return std::string(UhdmName(p->UhdmType())) + ":" + std::string(p->VpiName());
}

// The FACE.  Never VpiFullName / VpiFile / line / col (RESUME §9: Compare reads
// none of them, and our hier_paths carry an EMPTY VpiFile).
static std::string faceOf(const class_typespec* c) {
    std::string f = std::string(c->VpiName());
    f += " | owner=" + ownerOf(c);
    f += " | defn=";
    f += c->Class_defn() ? std::string(c->Class_defn()->VpiName()) : "<none>";
    f += c->Typedef_alias() ? " | CLONE" : " | BASE";
    return f;
}

static void collect(const char* path, std::map<std::string, std::vector<Cell>>& out,
                    size_t& total) {
    Serializer s;
    if (s.Restore(std::string(path)).empty()) {
        printf("RESTORE_FAIL %s\n", path);
        exit(3);
    }
    for (auto& kv : s.AllObjects()) {
        const BaseClass* o = kv.first;
        if (!o || o->UhdmType() != uhdmclass_typespec) continue;
        const class_typespec* c = (const class_typespec*)o;
        Cell cell;
        cell.params = effSize(c->Parameters());
        cell.pas = effSizePa(c->Param_assigns());
        out[faceOf(c)].push_back(cell);
        ++total;
    }
}

int main(int argc, char** argv) {
    if (argc < 3) {
        fprintf(stderr, "usage: ctv212fills <golden.uhdm> <ours.uhdm>\n");
        return 2;
    }
    std::map<std::string, std::vector<Cell>> G, O;
    size_t gt = 0, ot = 0;
    collect(argv[1], G, gt);
    collect(argv[2], O, ot);

    size_t lost = 0, extra = 0, sized = 0, unpG = 0, unpO = 0;
    std::map<std::string, int> lostRows, extraRows, sizeRows;
    for (auto& kv : G) {
        auto it = O.find(kv.first);
        if (it == O.end()) { unpG += kv.second.size(); continue; }
        // MULTISET join: sort both sides' cells by (params, pas) and pair by
        // rank.  Faces repeat (the UVM registry family repeats 50+ times), and
        // a dict keyed on the face alone would drop every repeat but one.
        auto a = kv.second, b = it->second;
        auto by = [](const Cell& x, const Cell& y) {
            return x.params != y.params ? x.params < y.params : x.pas < y.pas;
        };
        std::sort(a.begin(), a.end(), by);
        std::sort(b.begin(), b.end(), by);
        size_t n = a.size() < b.size() ? a.size() : b.size();
        if (a.size() > n) unpG += a.size() - n;
        if (b.size() > n) unpO += b.size() - n;
        for (size_t i = 0; i < n; i++) {
            if (a[i].params && !b[i].params) { ++lost; lostRows[kv.first]++; }
            else if (!a[i].params && b[i].params) { ++extra; extraRows[kv.first]++; }
            else if (a[i].params != b[i].params) { ++sized; sizeRows[kv.first]++; }
        }
    }
    for (auto& kv : O)
        if (!G.count(kv.first)) unpO += kv.second.size();

    printf("golden class_typespecs=%zu  ours=%zu  faces g=%zu o=%zu\n", gt, ot,
           G.size(), O.size());
    printf("FILL_LOST=%zu FILL_EXTRA=%zu FILL_SIZE=%zu UNPAIRED_GOLDEN=%zu UNPAIRED_OURS=%zu\n",
           lost, extra, sized, unpG, unpO);
    for (auto& kv : lostRows) printf("LOST  x%-3d %s\n", kv.second, kv.first.c_str());
    for (auto& kv : extraRows) printf("EXTRA x%-3d %s\n", kv.second, kv.first.c_str());
    for (auto& kv : sizeRows) printf("SIZE  x%-3d %s\n", kv.second, kv.first.c_str());
    return 0;
}
