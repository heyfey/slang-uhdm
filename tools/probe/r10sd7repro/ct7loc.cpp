// r10sd7 — THE FUNCTION-BODY-LOCAL CENSUS.  Every variable declared in a
// subroutine's BODY (the `begin` block's `Variables`, and the routine's own
// `Variables`), with the identity of its typespec and that typespec's
// `vpiInstance` — on both sides, keyed by owner routine.
//
// This is the population the head sits in.  `ct4scan`'s `visited`-pool
// suppression scan (sd4's instrument, re-run here) returns 21 singleton killers
// and exactly ONE with no killer below it:
//
//   class_typespec@199:3-199:20   uvm_globals.svh
//     owner class_var(cs)@199:21-199:23
//       <- begin@199:3-199:24
//       <- function(uvm_report_warning)@191:1-204:12
//       <- package(uvm_pkg)
//
// i.e. `uvm_coreservice_t cs;` — a STATEMENT-LOCAL of a PACKAGE-SCOPE function.
//
// The deepest-killer heuristic is UNSOUND on its own (sd4 R6: it named a
// `class_defn` whose `Compare` body cannot issue the arm at all), so it is used
// here only to point at a POPULATION, and the population is then read on both
// sides and decoded cell by cell.
//
// WHAT IT PRINTS PER ENTRY: the routine's own `vpiInstance`, the local's kind
// and span, the ref_typespec, the ACTUAL typespec's kind/name/span, and the
// actual typespec's `vpiInstance` resolved to a VIEW (`ALL:`/`TOP:`).
//
// GUARD: zero locals is a hard error.
//
// build: g++ -O2 -std=c++17 ct7loc.cpp -I ~/.local/include \
//          -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct7loc
// usage: ct7loc <db.uhdm> [routine-name-substring]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <map>
#include <set>
#include <string>
#include <vector>

using namespace UHDM;

static std::set<const BaseClass*> g_all, g_top;
static std::string span(const BaseClass* p) {
    return std::to_string(p->VpiLineNo()) + ":" + std::to_string(p->VpiColumnNo()) + "-" +
           std::to_string(p->VpiEndLineNo()) + ":" + std::to_string(p->VpiEndColumnNo());
}
static std::string ident(const BaseClass* p) {
    if (!p) return "<null>";
    std::string s = UhdmName(p->UhdmType());
    std::string nm(p->VpiName());
    if (!nm.empty()) s += "(" + nm + ")";
    return s + "@" + span(p);
}
static std::string view(const instance* i) {
    if (!i) return "<null>";
    std::string nm(i->VpiName());
    if (g_top.count(i)) return "TOP:" + nm;
    if (g_all.count(i)) return "ALL:" + nm;
    return "OTHER:" + std::string(UhdmName(i->UhdmType())) + "(" + nm + ")";
}

static size_t g_rows = 0;
static std::map<std::string, int> g_sum;

static void emitVar(const std::string& owner, const std::string& where, variables* v) {
    const typespec* ats = nullptr;
    auto* rt = v->Typespec();
    if (rt) ats = rt->Actual_typespec();
    const instance* in = ats ? ats->Instance() : nullptr;
    g_rows++;
    std::cout << "LOC " << owner << " | " << where << " | " << ident(v) << " | ts="
              << ident(ats) << " | inst=" << view(in) << "\n";
    g_sum[std::string(ats ? UhdmName(ats->UhdmType()) : "<no-ts>") + "  " + where +
          "  inst=" + view(in)]++;
}

// The body statement of a routine is a `begin`; its `Variables` are the
// statement-locals.  A routine can also carry them directly.
static void walkStmt(const std::string& owner, any* st) {
    if (!st) return;
    if (st->UhdmType() == uhdmbegin) {
        auto* b = (begin*)st;
        if (auto* vs = b->Variables())
            for (auto* v : *vs) if (v) emitVar(owner, "begin", v);
        if (auto* ss = b->Stmts())
            for (auto* s2 : *ss) walkStmt(owner, s2);
    } else if (st->UhdmType() == uhdmnamed_begin) {
        auto* b = (named_begin*)st;
        if (auto* vs = b->Variables())
            for (auto* v : *vs) if (v) emitVar(owner, "named_begin", v);
        if (auto* ss = b->Stmts())
            for (auto* s2 : *ss) walkStmt(owner, s2);
    }
}

static void walkTF(const std::string& home, task_func* tf, const std::string& filt) {
    std::string nm(tf->VpiName());
    if (!filt.empty() && nm.find(filt) == std::string::npos) return;
    std::string owner = home + "::" + nm + "@" + span(tf) + " tfInst=" + view(tf->Instance());
    if (auto* vs = tf->Variables())
        for (auto* v : *vs) if (v) emitVar(owner, "tf.Variables", v);
    walkStmt(owner, tf->Stmt());
}

int main(int argc, char** argv) {
    if (argc < 2) { std::cerr << "usage: ct7loc <db> [filter]\n"; return 2; }
    std::string filt = argc > 2 ? argv[2] : "";
    Serializer s;
    auto h = s.Restore(std::filesystem::path(argv[1]));
    if (h.empty()) { std::cerr << "RESTORE FAILED\n"; return 3; }
    auto* d = (design*)((uhdm_handle*)h[0])->object;
    if (auto* v = d->AllPackages()) for (auto* p : *v) g_all.insert(p);
    if (auto* v = d->TopPackages()) for (auto* p : *v) g_top.insert(p);

    auto doPkg = [&](package* p, const char* tag) {
        std::string home = std::string(tag) + ":" + std::string(p->VpiName());
        if (auto* v = p->Task_funcs()) for (auto* tf : *v) if (tf) walkTF(home, tf, filt);
        if (auto* v = p->Class_defns())
            for (auto* c : *v)
                if (c && c->Task_funcs())
                    for (auto* tf : *c->Task_funcs())
                        if (tf) walkTF(home + "/" + std::string(c->VpiName()), tf, filt);
    };
    if (auto* v = d->AllPackages()) for (auto* p : *v) doPkg(p, "ALL");
    if (auto* v = d->TopPackages()) for (auto* p : *v) doPkg(p, "TOP");

    std::cout << "[S] locals=" << g_rows << "\n";
    for (auto& [k, n] : g_sum) std::cout << "    " << n << "\t" << k << "\n";
    if (g_rows == 0) { std::cerr << "REFUSING TO REPORT: empty population\n"; return 5; }
    return 0;
}
