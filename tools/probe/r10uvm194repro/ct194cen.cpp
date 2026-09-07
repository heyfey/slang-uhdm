// r10uvm194 — THE RETURN-NAME REFERENCE CENSUS.  MEASUREMENT ONLY; the
// official ~/git-repos/UHDM/build/bin/uhdm-cmp is the sole judge.  LHS is
// ALWAYS golden (Surelog), RHS is ALWAYS ours.
//
// POPULATION: every `ref_obj` / `ref_var` whose `VpiName()` equals the LEAF
// name of the enclosing `function`/`task` — i.e. a reference to the
// subroutine's own IMPLICIT RETURN VARIABLE.  That is exactly the population
// § classRetNameDefViewNoBind37 unbinds and the population this pass's law
// carves an exemption out of.
//
// PAYLOAD (compare-visible only): the KIND, NAME and SPAN of the reference's
// `Actual_group` — `NONE` when it carries none.  `vpiParent` is never in the
// key or the payload: no generated `Compare` reads it (RESUME §9).
//
// KEY: the enclosing subroutine's own VpiName, the reference's span, and the
// NAMED ancestor chain (package / class_defn / module_inst / function / task
// names only).  The DEF and TOP listings of one subroutine produce the SAME
// key — deliberately, per RESUME §9's "keep the DEF/ELAB view out of the key":
// the two producers label the views differently, so the copies are counted as
// a MULTISET instead (§ 171's "4 spans x 2 copies" form).
//
// build: g++ -O2 -std=c++17 ct194cen.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct194cen
// usage: ct194cen <db.uhdm> <tag>        (one side per run; never merged here)
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <algorithm>
#include <cstdio>
#include <string>
#include <vector>

using namespace UHDM;

static std::string kn(const BaseClass* o) {
    return o ? std::string(UhdmName(o->UhdmType())) : std::string("<null>");
}
static const any* actualOf(const BaseClass* o) {
    if (const ref_obj* r = any_cast<const ref_obj*>(o)) return r->Actual_group();
    if (const ref_var* r = any_cast<const ref_var*>(o)) return r->Actual_group();
    return nullptr;
}
static std::string leaf(std::string_view n) {
    size_t p = n.rfind("::");
    return std::string(p == std::string_view::npos ? n : n.substr(p + 2));
}
// Only the NAMED scopes.  A statement chain adds nothing the law turns on.
static std::string homeChain(const BaseClass* o) {
    std::string s;
    for (const BaseClass* p = o->VpiParent(); p; p = p->VpiParent()) {
        const UHDM_OBJECT_TYPE t = p->UhdmType();
        if (t != uhdmpackage && t != uhdmclass_defn && t != uhdmmodule_inst &&
            t != uhdmfunction && t != uhdmtask)
            continue;
        s += " <";
        s += kn(p);
        s += ":";
        s += std::string(p->VpiName());
    }
    return s;
}
static const BaseClass* encFn(const BaseClass* o) {
    for (const BaseClass* p = o->VpiParent(); p; p = p->VpiParent())
        if (p->UhdmType() == uhdmfunction || p->UhdmType() == uhdmtask) return p;
    return nullptr;
}

int main(int argc, char** argv) {
    if (argc < 3) {
        fprintf(stderr, "usage: ct194cen <db.uhdm> <tag>\n");
        return 2;
    }
    const char* tag = argv[2];
    Serializer s;
    if (s.Restore(std::string(argv[1])).empty()) {
        printf("RESTORE_FAIL %s\n", argv[1]);
        return 3;
    }
    std::vector<std::string> rows;
    size_t cand = 0;
    for (auto& kv : s.AllObjects()) {
        const BaseClass* o = kv.first;
        if (!o) continue;
        const UHDM_OBJECT_TYPE t = o->UhdmType();
        if (t != uhdmref_obj && t != uhdmref_var) continue;
        const BaseClass* fn = encFn(o);
        if (!fn) continue;
        const std::string rn = leaf(o->VpiName());
        if (rn.empty() || rn != leaf(fn->VpiName())) continue;
        ++cand;
        const any* a = actualOf(o);
        char buf[1024];
        std::string act = "NONE";
        if (a) {
            char ab[512];
            snprintf(ab, sizeof(ab), "%s:%s@%u:%u", kn(a).c_str(),
                     std::string(a->VpiName()).c_str(), (unsigned)a->VpiLineNo(),
                     (unsigned)a->VpiColumnNo());
            act = ab;
        }
        snprintf(buf, sizeof(buf), "RET|%s|%s|%u:%u|%s|ACT=%s", tag,
                 std::string(fn->VpiName()).c_str(), (unsigned)o->VpiLineNo(),
                 (unsigned)o->VpiColumnNo(), homeChain(o).c_str(), act.c_str());
        rows.emplace_back(buf);
    }
    std::sort(rows.begin(), rows.end());
    for (auto& r : rows) printf("%s\n", r.c_str());
    printf("CAND|%s|%zu\n", tag, cand);
    return 0;
}
