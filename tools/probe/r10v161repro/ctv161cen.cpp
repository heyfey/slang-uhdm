// r10v161 — THE VERIFIER'S OWN CENSUS.  MEASUREMENT ONLY; the official
// `uhdm-cmp` is the sole judge.  LHS is ALWAYS golden (Surelog), RHS ours.
//
// Written independently of `ct161cen.cpp` and DELIBERATELY WIDER, so that a
// blind spot in the implementer's census cannot hide a regression:
//
//   REF| every object that CAN carry a `vpiActual` — `ref_obj` and its four
//        derived selects (`bit_select`, `part_select`, `indexed_part_select`,
//        `var_select`, reached IS-A), `ref_var`, `chandle_var`, `ref_module`
//        — with the actual it carries (NONE when bare).
//   VAR| every `vpiVariables` listing entry of every scope, with its
//        `vpiAutomatic` stamp.
//   CNT| every scope's listing COUNT, empty listings included.
//   OBJ| an IDENTITY census of EVERY object in the database (kind + name +
//        span + ancestor-kind chain).  This is the RESHAPE detector the
//        implementer's census does not have: an object that appears or
//        disappears, or moves home, is a cell here even when no reference
//        changed its actual.
//   TYP| every `ref_typespec`'s actual, so a typespec relink cannot hide.
//
// build: g++ -O2 -std=c++17 ctv161cen.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ctv161cen
// usage: ctv161cen <db.uhdm> <tag> [--nospan]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <algorithm>
#include <cstdio>
#include <cstring>
#include <string>
#include <vector>

using namespace UHDM;

static bool NOSPAN = false;

static std::string kindOf(const BaseClass* o) {
    return o ? std::string(UhdmName(o->UhdmType())) : std::string("<null>");
}
static std::string actOf(const BaseClass* a) {
    if (!a) return "NONE";
    return kindOf(a) + ":" + std::string(a->VpiName());
}
static std::string spanOf(const BaseClass* o) {
    if (NOSPAN) return "";
    char b[64];
    snprintf(b, sizeof b, "%u:%u", o->VpiLineNo(), (unsigned)o->VpiColumnNo());
    return b;
}
// Ancestor KIND (+ name for named scopes) chain, innermost first.  This is
// what separates an assertion CONDITION from its ACTION BLOCK and a depth-0
// statement from one inside an `if`.
static std::string homeChain(const BaseClass* o) {
    std::string s;
    int guard = 0;
    for (const BaseClass* p = o->VpiParent(); p && guard < 64; p = p->VpiParent(), ++guard) {
        s += "/";
        s += UhdmName(p->UhdmType());
        if (const operation* op = any_cast<const operation*>(p)) {
            char ob[24];
            snprintf(ob, sizeof ob, "#%d", (int)op->VpiOpType());
            s += ob;
        }
        const std::string n(p->VpiName());
        if (!n.empty()) { s += ":"; s += n; }
    }
    return s;
}

int main(int argc, char** argv) {
    if (argc < 3) { fprintf(stderr, "usage: ctv161cen <db> <tag> [--nospan]\n"); return 2; }
    for (int i = 3; i < argc; ++i)
        if (!strcmp(argv[i], "--nospan")) NOSPAN = true;
    Serializer s;
    if (s.Restore(std::string(argv[1])).empty()) {
        fprintf(stderr, "RESTORE_FAIL %s\n", argv[1]);
        return 3;
    }
    const std::string tag(argv[2]);
    std::vector<std::string> out;
    char b[4096];
    for (auto& kv : s.AllObjects()) {
        const BaseClass* o = kv.first;
        if (!o) continue;

        // ---- REF: everything that can carry a vpiActual ------------------
        const BaseClass* act = nullptr;
        bool isRef = false;
        if (const ref_obj* r = any_cast<const ref_obj*>(o)) { isRef = true; act = r->Actual_group(); }
        else if (const ref_var* r = any_cast<const ref_var*>(o)) { isRef = true; act = r->Actual_group(); }
        else if (const chandle_var* r = any_cast<const chandle_var*>(o)) { isRef = true; act = r->Actual_group(); }
        else if (const ref_module* r = any_cast<const ref_module*>(o)) { isRef = true; act = r->Actual_group(); }
        if (isRef) {
            snprintf(b, sizeof b, "REF|%s|%s|%s|%s|%s|ACT=%s", tag.c_str(),
                     kindOf(o).c_str(), std::string(o->VpiName()).c_str(),
                     spanOf(o).c_str(), homeChain(o).c_str(), actOf(act).c_str());
            out.push_back(b);
        }
        // ---- TYP: every ref_typespec's actual ----------------------------
        if (const ref_typespec* rt = any_cast<const ref_typespec*>(o)) {
            snprintf(b, sizeof b, "TYP|%s|%s|%s|%s|ACT=%s", tag.c_str(),
                     std::string(rt->VpiName()).c_str(), spanOf(rt).c_str(),
                     homeChain(rt).c_str(), actOf(rt->Actual_typespec()).c_str());
            out.push_back(b);
        }
        // ---- VAR / CNT: the listings -------------------------------------
        if (const scope* sc = any_cast<const scope*>(o)) {
            if (auto* v = sc->Variables())
                for (auto* var : *v) {
                    if (!var) continue;
                    snprintf(b, sizeof b, "VAR|%s|%s:%s@%u|%s|%s|%s|auto=%d",
                             tag.c_str(), kindOf(sc).c_str(),
                             std::string(sc->VpiName()).c_str(), sc->VpiLineNo(),
                             kindOf(var).c_str(),
                             std::string(var->VpiName()).c_str(),
                             spanOf(var).c_str(), (int)var->VpiAutomatic());
                    out.push_back(b);
                }
            snprintf(b, sizeof b, "CNT|%s|%s:%s@%s|vars=%zu", tag.c_str(),
                     kindOf(sc).c_str(), std::string(sc->VpiName()).c_str(),
                     spanOf(sc).c_str(),
                     sc->Variables() ? sc->Variables()->size() : 0);
            out.push_back(b);
        }
        // ---- OBJ: the identity census of EVERY object --------------------
        snprintf(b, sizeof b, "OBJ|%s|%s|%s|%s|%s", tag.c_str(),
                 kindOf(o).c_str(), std::string(o->VpiName()).c_str(),
                 spanOf(o).c_str(), homeChain(o).c_str());
        out.push_back(b);
    }
    std::sort(out.begin(), out.end());
    for (auto& l : out) printf("%s\n", l.c_str());
    return 0;
}
