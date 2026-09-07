// r10uvm188 — THE ENUM-CONSTANT DECOMPILE / SIZE / VALUE CENSUS.
// MEASUREMENT ONLY; nothing here is an acceptance judge (the official
// `uhdm-cmp` and `scripts/verify_golden.py` are).
//
// LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
//
// `enum_const::Compare` runs `expr::Compare` first, which reads
// VpiDecompile then VpiSize then Typespec; `enum_const::Compare` then reads
// VpiName, VpiDecompile and VpiSize again.  VpiValue is NOT a compared field
// on an enum_const (only `constant::Compare` reads it) — it is printed here
// anyway because it is the dump-visible witness of Surelog's Value TYPE, the
// same object the size comes from.
//
// The walk is FLAT: `Serializer::AllObjects()` after a restore holds every
// object in the database, so no per-kind recursion can miss an enum_const
// hiding under a typedef, a class, a task-func local or a generate scope.
// The DEF and ELAB listings of one constant carry the SAME key, so the census
// is a MULTISET (last-writer dicts drop rows — RESUME §9).
//
// usage: ct188cen <file.uhdm> [tag]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <iostream>
#include <map>
#include <string>
using namespace UHDM;

static std::string span(const any* o) {
    if (!o) return "-";
    return std::to_string(o->VpiLineNo()) + ":" +
           std::to_string(o->VpiColumnNo()) + "-" +
           std::to_string(o->VpiEndLineNo()) + ":" +
           std::to_string(o->VpiEndColumnNo());
}
static std::string base(std::string_view p) {
    size_t s = p.rfind('/');
    return std::string(s == std::string_view::npos ? p : p.substr(s + 1));
}
// A field that may hold a separator must never be printed raw into a
// separator-joined row: `|` in a decompile ({a|b}) would forge a column.
static std::string esc(std::string_view v) {
    std::string o;
    for (char c : v) {
        if (c == '|') o += "\\p";
        else if (c == '\n') o += "\\n";
        else if (c == '\t') o += "\\t";
        else o += c;
    }
    return o;
}

int main(int argc, char** argv) {
    if (argc < 2) { std::cerr << "usage: ct188cen <file.uhdm> [tag]\n"; return 2; }
    const std::string tag = argc > 2 ? argv[2] : "-";
    Serializer s;
    const std::vector<vpiHandle> restored = s.Restore(std::string(argv[1]));
    if (restored.empty()) { std::cerr << "FATAL: nothing restored from " << argv[1] << "\n"; return 3; }
    Serializer::IdMap all = s.AllObjects();
    // Deterministic order: the row set must not depend on the id map's
    // iteration order, so every row is sorted before it is printed.
    std::map<std::string, int> rows;
    for (const auto& kv : all) {
        const BaseClass* o = kv.first;
        if (!o || o->UhdmType() != uhdmenum_const) continue;
        const enum_const* ec = (const enum_const*)o;
        const any* par = ec->VpiParent();
        std::string pk = par ? std::string(UhdmName(par->UhdmType())) : "NOPARENT";
        std::string pn = par ? std::string(par->VpiName()) : "-";
        std::string row =
            tag + "|" + base(ec->VpiFile()) + "|" + pk + "|" + esc(pn) + "|" +
            esc(ec->VpiName()) + "|" + span(ec) + "|DEC=" + esc(ec->VpiDecompile()) +
            "|SZ=" + std::to_string(ec->VpiSize()) + "|VAL=" + esc(ec->VpiValue());
        rows[row]++;
    }
    for (const auto& r : rows) std::cout << r.first << "|N=" << r.second << "\n";
    return 0;
}
