// r10uvm181 — THE BINDING CENSUS.  MEASUREMENT ONLY; the official
// `~/git-repos/UHDM/build/bin/uhdm-cmp` is the sole judge.
// LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
//
// Joins golden's and our `vpiActual` for EVERY reference (`ref_obj`,
// `ref_var`, `bit_select`) in the design, as a MULTISET keyed on the face
// (owning package + enclosing subroutine + kind + name + line:col + the
// occurrence's rank at that face), so colliding keys cannot silently drop a
// row the way a last-writer dictionary does.
//
// Each row is classified twice:
//   * LOOPVAR — the name is the loop variable of an ENCLOSING foreach_stmt
//     (the family this pass is about), else OTHER.
//   * EMPTYTF — the enclosing subroutine has NEITHER an Io_decls entry NOR a
//     Variables entry of its own (`function void f();` whose only declarations
//     live inside a block).  That is exactly the shape whose clone body
//     TaskFuncEmit.cpp's `if (!lm9.empty())` refuses to register, so it is the
//     blast radius of removing that guard.
//
// Cells (golden vs ours):
//   MISS      golden BOUND, ours BARE          — what the law must win
//   EXTRA     golden BARE,  ours BOUND         — an AWAY-GOLDEN cell
//   BINDWRONG both BOUND, different target face — also AWAY-GOLDEN
//   OK        both BOUND on the same face, or both BARE
//
// build: g++ -O2 -std=c++17 ct181cen.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct181cen
// usage: ct181cen <golden.uhdm> <ours.uhdm> [--rows]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <algorithm>
#include <cstdio>
#include <cstring>
#include <map>
#include <string>
#include <vector>

using namespace UHDM;

static std::string face(const BaseClass* o) {
    if (!o) return "-";
    char b[600];
    const std::string k(UhdmName(o->UhdmType()));
    const std::string n(o->VpiName());
    snprintf(b, sizeof b, "%s:%s@%u:%u", k.c_str(), n.c_str(), o->VpiLineNo(),
             (unsigned)o->VpiColumnNo());
    return b;
}
static const BaseClass* actualOf(const BaseClass* o) {
    if (auto* r = any_cast<const ref_obj*>(o)) return r->Actual_group();
    if (auto* r = any_cast<const ref_var*>(o)) return r->Actual_group();
    if (auto* r = any_cast<const bit_select*>(o)) return r->Actual_group();
    return nullptr;
}
static bool isRef(const BaseClass* o) {
    auto t = o->UhdmType();
    return t == uhdmref_obj || t == uhdmref_var || t == uhdmbit_select;
}
// Does an ENCLOSING foreach list a loop variable of this name?
static bool loopVarName(const BaseClass* o, std::string_view nm) {
    for (const BaseClass* p = o->VpiParent(); p; p = p->VpiParent()) {
        if (p->UhdmType() == uhdmforeach_stmt) {
            if (auto* lv = ((const foreach_stmt*)p)->VpiLoopVars())
                for (auto* v : *lv)
                    if (v && v->VpiName() == nm) return true;
        }
        if (p->UhdmType() == uhdmfunction || p->UhdmType() == uhdmtask) break;
    }
    return false;
}
struct Ctx { const task_func* tf; std::string pkg; };
static Ctx ctxOf(const BaseClass* o) {
    Ctx c{nullptr, "-"};
    for (const BaseClass* p = o->VpiParent(); p; p = p->VpiParent()) {
        if (!c.tf && (p->UhdmType() == uhdmfunction || p->UhdmType() == uhdmtask))
            c.tf = (const task_func*)p;
        if (p->UhdmType() == uhdmpackage) { c.pkg = std::string(p->VpiName()); break; }
        if (p->UhdmType() == uhdmmodule_inst) { c.pkg = "MOD:" + std::string(p->VpiName()); break; }
    }
    return c;
}
static bool emptyTf(const task_func* tf) {
    if (!tf) return false;
    bool io = tf->Io_decls() && !tf->Io_decls()->empty();
    bool vs = tf->Variables() && !tf->Variables()->empty();
    return !io && !vs;
}

struct Row { std::string tgt; };

static void collect(Serializer& S, std::map<std::string, std::vector<Row>>& out) {
    std::map<std::string, int> rank;
    std::vector<const BaseClass*> objs;
    for (auto& kv : S.AllObjects())
        if (kv.first && isRef(kv.first)) objs.push_back(kv.first);
    // Deterministic order so the per-face rank is reproducible across runs.
    std::sort(objs.begin(), objs.end(), [](const BaseClass* a, const BaseClass* b) {
        return a->UhdmId() < b->UhdmId();
    });
    for (const BaseClass* o : objs) {
        Ctx c = ctxOf(o);
        const std::string nm(o->VpiName());
        char b[1200];
        snprintf(b, sizeof b, "%s|%s|%s|%s|%s|%u:%u",
                 c.pkg.c_str(),
                 c.tf ? std::string(c.tf->VpiName()).c_str() : "-",
                 emptyTf(c.tf) ? "EMPTYTF" : "HASLOCALS",
                 loopVarName(o, nm) ? "LOOPVAR" : "OTHER",
                 (std::string(UhdmName(o->UhdmType())) + ":" + nm).c_str(),
                 o->VpiLineNo(), (unsigned)o->VpiColumnNo());
        std::string key(b);
        key += "#" + std::to_string(rank[key]++);
        out[key].push_back(Row{face(actualOf(o))});
    }
}

int main(int argc, char** argv) {
    if (argc < 3) { fprintf(stderr, "usage: ct181cen <golden> <ours> [--rows]\n"); return 2; }
    const bool rows = argc > 3 && !strcmp(argv[3], "--rows");
    Serializer sg, so;
    if (sg.Restore(std::string(argv[1])).empty()) { printf("RESTORE_FAIL golden\n"); return 3; }
    if (so.Restore(std::string(argv[2])).empty()) { printf("RESTORE_FAIL ours\n"); return 3; }
    std::map<std::string, std::vector<Row>> G, O;
    collect(sg, G);
    collect(so, O);
    // one bucket per (EMPTYTF|HASLOCALS) x (LOOPVAR|OTHER)
    struct Cell { long miss = 0, extra = 0, wrong = 0, ok = 0, onlyG = 0, onlyO = 0; };
    std::map<std::string, Cell> cells;
    auto bucket = [](const std::string& k) {
        // key = pkg|tf|EMPTYTF|LOOPVAR|kind:name|line:col#rank
        size_t p1 = k.find('|'); size_t p2 = k.find('|', p1 + 1);
        size_t p3 = k.find('|', p2 + 1); size_t p4 = k.find('|', p3 + 1);
        return k.substr(p2 + 1, p4 - p2 - 1);
    };
    std::vector<std::string> missRows, extraRows, wrongRows;
    for (auto& [k, gv] : G) {
        auto oit = O.find(k);
        Cell& c = cells[bucket(k)];
        if (oit == O.end()) { c.onlyG++; continue; }
        const std::string& g = gv[0].tgt;
        const std::string& o = oit->second[0].tgt;
        if (g == "-" && o == "-") c.ok++;
        else if (g != "-" && o == "-") { c.miss++; if (rows) missRows.push_back(k + "  golden=" + g); }
        else if (g == "-" && o != "-") { c.extra++; if (rows) extraRows.push_back(k + "  ours=" + o); }
        else if (g == o) c.ok++;
        else { c.wrong++; if (rows) wrongRows.push_back(k + "  golden=" + g + "  ours=" + o); }
    }
    for (auto& [k, ov] : O)
        if (!G.count(k)) cells[bucket(k)].onlyO++;
    printf("%-22s %8s %8s %9s %8s %8s %8s\n", "BUCKET", "MISS", "EXTRA",
           "BINDWRONG", "OK", "ONLY-G", "ONLY-O");
    long tm = 0, te = 0, tw = 0;
    for (auto& [b, c] : cells) {
        printf("%-22s %8ld %8ld %9ld %8ld %8ld %8ld\n", b.c_str(), c.miss,
               c.extra, c.wrong, c.ok, c.onlyG, c.onlyO);
        tm += c.miss; te += c.extra; tw += c.wrong;
    }
    printf("TOTAL MISS=%ld EXTRA=%ld BINDWRONG=%ld\n", tm, te, tw);
    if (rows) {
        auto dump = [](const char* t, std::vector<std::string>& v) {
            std::sort(v.begin(), v.end());
            printf("---- %s (%zu) ----\n", t, v.size());
            for (auto& s : v) printf("  %s\n", s.c_str());
        };
        dump("MISS", missRows);
        dump("EXTRA", extraRows);
        dump("BINDWRONG", wrongRows);
    }
    return 0;
}
