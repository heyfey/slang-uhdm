// r10uvm195 — THE LISTING CENSUS.  MEASUREMENT ONLY; the official
// `~/git-repos/UHDM/build/bin/uhdm-cmp` is the sole judge.  LHS is ALWAYS
// golden (Surelog), RHS is ALWAYS ours.
//
// One row per (SCOPE, index) slot of every `vpiVariables` listing in the
// database — the task/function's OWN listing and every begin / named_begin /
// fork arm alike — with the payload the JUDGE reads on that slot:
//
//   LIST|<tag>|<scope kind>|<scope name>@<span>|<idx>|<var kind>|<var name>|ACT=<actual kind>:<actual name>
//
// and one DUMP-ONLY row per slot carrying `vpiParent` (which NO generated
// `Compare` reads — RESUME §9 — so it must never enter the key or the payload):
//
//   PAR|<tag>|<scope kind>|<scope name>@<span>|<idx>|<var name>|<parent kind>@<span>
//
// The `<tag>` column is the producer label; `score195.py` strips it before the
// multiset join so a golden row and an ours row of the same slot collide.
//
// build: g++ -O2 -std=c++17 ct195cen.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct195cen
// usage: ct195cen <db.uhdm> <tag>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <algorithm>
#include <cstdio>
#include <string>
#include <vector>

using namespace UHDM;

static std::string span(const BaseClass* o) {
    char b[80];
    snprintf(b, sizeof b, "%u:%u-%u:%u", o->VpiLineNo(), (unsigned)o->VpiColumnNo(),
             o->VpiEndLineNo(), (unsigned)o->VpiEndColumnNo());
    return b;
}
// The listing OWNER's home: every package / class_defn / module_inst on the
// parent chain, outermost last.  Without it a wildcard-import CLONE's listing
// and its HOME's collapse onto one key (both `task:C::t@<same span>`) and the
// join silently pairs the wrong rows.
static std::string home(const BaseClass* o) {
    std::string s;
    int g = 0;
    for (const BaseClass* p = o->VpiParent(); p && g < 40; p = p->VpiParent(), ++g) {
        const UHDM_OBJECT_TYPE t = p->UhdmType();
        if (t != uhdmpackage && t != uhdmclass_defn && t != uhdmmodule_inst)
            continue;
        s += "<";
        s += UhdmName(t);
        s += ":";
        s += std::string(p->VpiName());
    }
    return s;
}
// The scope's own identity.  A task_func is named; a begin carries the
// enclosing subroutine's fullname, so its SPAN is what separates two begins of
// one subroutine.
static std::string scopeKey(const BaseClass* o) {
    std::string s(UhdmName(o->UhdmType()));
    s += ":";
    s += std::string(o->VpiName());
    s += "@";
    s += span(o);
    s += home(o);
    return s;
}
static std::string actOf(const any* v) {
    const any* a = nullptr;
    if (v->UhdmType() == uhdmref_var) a = ((const ref_var*)v)->Actual_group();
    else if (v->UhdmType() == uhdmref_obj) a = ((const ref_obj*)v)->Actual_group();
    if (!a) return "-";
    std::string s(UhdmName(a->UhdmType()));
    s += ":";
    s += std::string(a->VpiName());
    s += "@";
    s += span(a);
    return s;
}

int main(int argc, char** argv) {
    if (argc < 3) { fprintf(stderr, "usage: ct195cen <db.uhdm> <tag>\n"); return 2; }
    Serializer S;
    if (S.Restore(std::string(argv[1])).empty()) { printf("RESTORE_FAIL\n"); return 3; }
    const char* tag = argv[2];
    std::vector<std::string> rows;
    for (auto& kv : S.AllObjects()) {
        const BaseClass* X = kv.first;
        if (!X) continue;
        const VectorOfvariables* vars = nullptr;
        switch (X->UhdmType()) {
            case uhdmtask: vars = ((const task*)X)->Variables(); break;
            case uhdmfunction: vars = ((const function*)X)->Variables(); break;
            case uhdmbegin: vars = ((const begin*)X)->Variables(); break;
            case uhdmnamed_begin: vars = ((const named_begin*)X)->Variables(); break;
            case uhdmfork_stmt: vars = ((const fork_stmt*)X)->Variables(); break;
            case uhdmnamed_fork: vars = ((const named_fork*)X)->Variables(); break;
            default: continue;
        }
        if (!vars) continue;
        const std::string sk = scopeKey(X);
        for (size_t i = 0; i < vars->size(); ++i) {
            const variables* v = (*vars)[i];
            if (!v) { rows.push_back(std::string("LIST|") + tag + "|" + sk + "|" +
                                     std::to_string(i) + "|<null>||ACT=-"); continue; }
            rows.push_back(std::string("LIST|") + tag + "|" + sk + "|" +
                           std::to_string(i) + "|" + std::string(UhdmName(v->UhdmType())) +
                           "|" + std::string(v->VpiName()) + "|ACT=" + actOf(v));
            const BaseClass* p = v->VpiParent();
            rows.push_back(std::string("PAR|") + tag + "|" + sk + "|" +
                           std::to_string(i) + "|" + std::string(v->VpiName()) + "|" +
                           (p ? std::string(UhdmName(p->UhdmType())) + "@" + span(p)
                              : std::string("<null>")));
        }
    }
    std::sort(rows.begin(), rows.end());
    for (auto& r : rows) printf("%s\n", r.c_str());
    return 0;
}
