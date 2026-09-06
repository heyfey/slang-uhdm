// r10uvm169 — THE PACKAGE-FUNCTION RETURN CENSUS.  MEASUREMENT ONLY; the
// official `~/git-repos/UHDM/build/bin/uhdm-cmp` is the sole judge; this tool
// only reports.  LHS is ALWAYS golden (Surelog), RHS is ALWAYS ours.
//
// THE HEAD this pass owns is a `return_stmt::VpiCondition` KIND mismatch
// (`BaseClass::Compare`'s FIRST test, `VpiType`), so the census row must carry
// the condition's KIND and every field the judge reads on it —
// `expr::Compare` reads VpiDecompile, VpiSize and the TYPESPEC chain
// (`~/git-repos/UHDM/build/generated/src/expr.cpp:83-102`), `constant::Compare`
// adds VpiConstType — and NOTHING the judge does not read (no VpiFullName, no
// vpiParent).
//
// FAMILIES
//   RET| one row per `return_stmt`, keyed by the OWNING SUBROUTINE'S
//        vpiFullName x the return_stmt's SPAN, valued by the condition's
//        KIND + its compare-visible payload (DEC / SIZE / CT / the actual
//        typespec's KIND+NAME) and, for a `ref_obj`, the NAME it carries and
//        the KIND its vpiActual resolves to.  The DEF and ELAB listings of one
//        package produce the SAME key, so the value is a MULTISET per key
//        (RESUME §9: never put the view label in the key — the two producers
//        label it differently).
//   OBJ| a whole-database depth-keyed identity census (KIND x NAME x SPAN x
//        HOME) so collateral anywhere else is visible even when no return
//        moved.  Suppressed with --noobj.
//
// usage: ct169cen <db.uhdm> <tag> [--nospan] [--noobj]
// build: g++ -O2 -std=c++17 ct169cen.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct169cen
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <algorithm>
#include <cstdio>
#include <cstring>
#include <string>
#include <vector>

using namespace UHDM;

static bool NOSPAN = false;
static bool NOOBJ = false;

static std::string kindOf(const BaseClass* o) {
    return o ? std::string(UhdmName(o->UhdmType())) : std::string("<null>");
}
static std::string spanOf(const BaseClass* o) {
    if (NOSPAN || !o) return "";
    char b[64];
    snprintf(b, sizeof b, "%u:%u-%u:%u", o->VpiLineNo(), (unsigned)o->VpiColumnNo(),
             o->VpiEndLineNo(), (unsigned)o->VpiEndColumnNo());
    return b;
}
static std::string clean(std::string d) {
    for (auto& c : d)
        if (c == '\n' || c == '\r' || c == '|' || c == '\t') c = ' ';
    if (d.size() > 90) d = d.substr(0, 90) + "...";
    return d;
}
// The enclosing NAMED containers, outermost last.  Name-based, not
// pointer-based: the two databases are different arenas.
static std::string homeChain(const BaseClass* o) {
    std::string s;
    int guard = 0;
    for (const BaseClass* p = o->VpiParent(); p && guard < 24; p = p->VpiParent(), ++guard) {
        switch (p->UhdmType()) {
            case uhdmfunction:
            case uhdmtask:
            case uhdmclass_defn:
            case uhdmpackage:
            case uhdmmodule_inst:
            case uhdminterface_inst:
            case uhdmprogram:
                s += "<";
                s += UhdmName(p->UhdmType());
                s += ":";
                s += p->VpiName();
                break;
            default:
                break;
        }
    }
    return s.empty() ? "<none>" : s;
}
// The subroutine that OWNS this statement, by vpiFullName — the one string that
// separates a wildcard-import CLONE (`adpcm_pkg::uvm_revision_string`) from its
// HOME (`uvm_pkg::uvm_revision_string`), which is the whole population split
// this pass turns on.
static std::string ownerOf(const BaseClass* o) {
    int guard = 0;
    for (const BaseClass* p = o->VpiParent(); p && guard < 32; p = p->VpiParent(), ++guard) {
        if (p->UhdmType() == uhdmfunction) {
            const function* f = (const function*)p;
            std::string n(f->VpiFullName());
            return n.empty() ? std::string(f->VpiName()) : n;
        }
        if (p->UhdmType() == uhdmtask) {
            const task* t = (const task*)p;
            std::string n(t->VpiFullName());
            return n.empty() ? std::string(t->VpiName()) : n;
        }
    }
    return "<nosub>";
}
// The compare-visible payload of ONE return condition.
static std::string payloadOf(const BaseClass* c) {
    if (!c) return "K=<null>";
    std::string s = "K=" + kindOf(c);
    if (const expr* e = any_cast<const expr*>(c)) {
        s += ";DEC=" + clean(std::string(e->VpiDecompile()));
        char b[64];
        snprintf(b, sizeof b, ";SZ=%d", (int)e->VpiSize());
        s += b;
        const ref_typespec* rt = e->Typespec();
        const typespec* at = rt ? rt->Actual_typespec() : nullptr;
        s += ";TS=" + (rt ? (at ? kindOf(at) + ":" + clean(std::string(at->VpiName()))
                                : std::string("<rt-null-actual>"))
                          : std::string("<none>"));
    }
    if (const constant* k = any_cast<const constant*>(c)) {
        char b[64];
        snprintf(b, sizeof b, ";CT=%d", k->VpiConstType());
        s += b;
        s += ";VAL=" + clean(std::string(k->VpiValue()));
    }
    if (const ref_obj* r = any_cast<const ref_obj*>(c)) {
        s += ";NM=" + clean(std::string(r->VpiName()));
        s += ";ACT=" + kindOf(r->Actual_group());
    }
    return s;
}

int main(int argc, char** argv) {
    if (argc < 3) {
        fprintf(stderr, "usage: ct169cen <db.uhdm> <tag> [--nospan] [--noobj]\n");
        return 2;
    }
    for (int i = 3; i < argc; ++i) {
        if (!strcmp(argv[i], "--nospan")) NOSPAN = true;
        if (!strcmp(argv[i], "--noobj")) NOOBJ = true;
    }
    Serializer s;
    if (s.Restore(std::string(argv[1])).empty()) {
        fprintf(stderr, "RESTORE_FAIL %s\n", argv[1]);
        return 3;
    }
    const std::string tag(argv[2]);
    std::vector<std::string> out;
    char b[16384];
    for (auto& kv : s.AllObjects()) {
        const BaseClass* o = kv.first;
        if (!o) continue;
        if (o->UhdmType() == uhdmreturn_stmt) {
            const return_stmt* r = (const return_stmt*)o;
            snprintf(b, sizeof b, "RET|%s|%s|%s|%s", tag.c_str(),
                     ownerOf(o).c_str(), spanOf(o).c_str(),
                     payloadOf(r->VpiCondition()).c_str());
            out.push_back(b);
        }
        if (!NOOBJ) {
            snprintf(b, sizeof b, "OBJ|%s|%s|%s|%s|%s", tag.c_str(), kindOf(o).c_str(),
                     clean(std::string(o->VpiName())).c_str(), spanOf(o).c_str(),
                     homeChain(o).c_str());
            out.push_back(b);
        }
    }
    std::sort(out.begin(), out.end());
    for (auto& l : out) puts(l.c_str());
    return 0;
}
