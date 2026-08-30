// r10uvm161 — THE BINDING CENSUS.  MEASUREMENT ONLY; the official `uhdm-cmp`
// is the sole judge.  LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
//
// Two cell families, one line each, both keyed on an IDENTITY that survives
// the DEF/ELAB duplication and the two producers' different ids:
//
//   REF|<tag>|<refkind>|<name>|<line>:<col>|<home chain>|ACT=<kind>:<name>
//        every `ref_obj` / `ref_var` / `bit_select`, with the vpiActual it
//        carries (NONE when it carries none) — this law's cell.
//   VAR|<tag>|<scope kind>:<scope name>@<line>|<varkind>|<name>|<line>:<col>|auto=<n>
//        every `vpiVariables` LISTING of every scope — the listing COUNTS the
//        brief asks to be scored per scope, in both columns.
//
// The `home chain` is the ancestor kinds from the reference up to the design,
// which is what tells an assertion CONDITION from an assertion ACTION BLOCK
// and a depth-0 statement from one inside an `if`.  Spans are printed because
// they are the human handle; they are NOT what the judge reads (RESUME.md §9).
//
// build: g++ -O2 -std=c++17 ct161cen.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct161cen
// usage: ct161cen <db.uhdm> <tag>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <algorithm>
#include <cstdio>
#include <string>
#include <vector>

using namespace UHDM;

static std::string kindOf(const BaseClass* o) {
    return o ? std::string(UhdmName(o->UhdmType())) : std::string("<null>");
}
static std::string actOf(const BaseClass* a) {
    if (!a) return "NONE";
    return kindOf(a) + ":" + std::string(a->VpiName());
}
// The ancestor KIND chain, innermost first.  A `ref_obj` under
// `operation < immediate_assert < begin < function` is the assertion
// CONDITION; one under `... < begin < immediate_assert < ...` is its ACTION
// BLOCK.  Names are included for scopes so two same-shaped homes stay apart.
static std::string homeChain(const BaseClass* o) {
    std::string s;
    for (const BaseClass* p = o->VpiParent(); p; p = p->VpiParent()) {
        s += "/";
        s += UhdmName(p->UhdmType());
        const std::string n(p->VpiName());
        if (!n.empty()) { s += ":"; s += n; }
    }
    return s;
}

int main(int argc, char** argv) {
    if (argc < 3) { fprintf(stderr, "usage: ct161cen <db> <tag>\n"); return 2; }
    Serializer s;
    if (s.Restore(std::string(argv[1])).empty()) { fprintf(stderr, "RESTORE_FAIL %s\n", argv[1]); return 3; }
    const std::string tag(argv[2]);
    std::vector<std::string> out;
    char b[2400];
    for (auto& kv : s.AllObjects()) {
        const BaseClass* o = kv.first;
        if (!o) continue;
        const BaseClass* act = nullptr;
        bool isRef = false;
        if (const ref_obj* r = any_cast<const ref_obj*>(o)) { isRef = true; act = r->Actual_group(); }
        else if (const ref_var* r = any_cast<const ref_var*>(o)) { isRef = true; act = r->Actual_group(); }
        else if (const bit_select* r = any_cast<const bit_select*>(o)) { isRef = true; act = r->Actual_group(); }
        if (isRef) {
            snprintf(b, sizeof b, "REF|%s|%s|%s|%u:%u|%s|ACT=%s", tag.c_str(),
                     kindOf(o).c_str(), std::string(o->VpiName()).c_str(),
                     o->VpiLineNo(), (unsigned)o->VpiColumnNo(),
                     homeChain(o).c_str(), actOf(act).c_str());
            out.push_back(b);
        }
        if (const scope* sc = any_cast<const scope*>(o)) {
            if (auto* v = sc->Variables())
                for (auto* var : *v) {
                    if (!var) continue;
                    snprintf(b, sizeof b, "VAR|%s|%s:%s@%u|%s|%s|%u:%u|auto=%d",
                             tag.c_str(), kindOf(sc).c_str(),
                             std::string(sc->VpiName()).c_str(), sc->VpiLineNo(),
                             kindOf(var).c_str(),
                             std::string(var->VpiName()).c_str(),
                             var->VpiLineNo(), (unsigned)var->VpiColumnNo(),
                             (int)var->VpiAutomatic());
                    out.push_back(b);
                }
            // The LISTING COUNT per scope, scored explicitly in both columns
            // (a scope that lists NOTHING must still produce a cell, or an
            // AWAY listing on our side would have nothing to be away from).
            snprintf(b, sizeof b, "CNT|%s|%s:%s@%u:%u|vars=%zu", tag.c_str(),
                     kindOf(sc).c_str(), std::string(sc->VpiName()).c_str(),
                     sc->VpiLineNo(), (unsigned)sc->VpiColumnNo(),
                     sc->Variables() ? sc->Variables()->size() : 0);
            out.push_back(b);
        }
    }
    std::sort(out.begin(), out.end());
    for (auto& l : out) printf("%s\n", l.c_str());
    return 0;
}
