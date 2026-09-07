// r10uvm183 — THE FOREACH CENSUS READER.  MEASUREMENT ONLY; the official
// `uhdm-cmp` is the sole judge.  LHS is ALWAYS golden, RHS ALWAYS ours.
//
// `--fe` prints one TSV row per `foreach_stmt` in the database:
//
//   FE <line>:<col> <tf-kind>:<tf-name> <scope-kind>:<scope-name>#<scope-id>
//      ARR=<kind>(<name>)@<span>  ARRTS=<kind>(<name>)@<span> INST=<kind>:<name>#<id>
//      LV=<kind>(<name>)|<ts-kind>(<ts-name>)@<span>[,...]
//
// The owning SCOPE carries its UhdmId so the DEF and ELAB copies of one source
// line are distinct rows (a corpus database holds every view in one file), and
// the span is printed WITHOUT the file, because our objects carry an empty
// `vpiFile` and Surelog's carry a path — a key containing the file joins
// nothing (RESUME.md §9, census traps).
//
// `--utsinst` prints every `unsupported_typespec` with its `Instance()`, for
// the home-package-instance link question.
//
// build: g++ -O2 -std=c++17 ct183cen.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct183cen
// usage: ct183cen <db.uhdm> [--fe] [--utsinst]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <algorithm>
#include <cstdio>
#include <cstring>
#include <string>
#include <vector>

using namespace UHDM;

static std::string kindOf(const BaseClass* o) {
    return o ? std::string(UhdmName(o->UhdmType())) : std::string("<null>");
}
static std::string face(const BaseClass* o) {
    if (!o) return "<null>";
    char b[600];
    snprintf(b, sizeof b, "%s(%s)@%u:%u-%u:%u", kindOf(o).c_str(),
             std::string(o->VpiName()).c_str(), o->VpiLineNo(),
             (unsigned)o->VpiColumnNo(), o->VpiEndLineNo(),
             (unsigned)o->VpiEndColumnNo());
    return b;
}
static const ref_typespec* tsRefOf(const BaseClass* o) {
    if (!o) return nullptr;
    if (auto* v = any_cast<const variables*>(o)) return v->Typespec();
    if (auto* r = any_cast<const ref_obj*>(o)) return r->Typespec();
    if (o->UhdmType() == uhdmio_decl) return ((const io_decl*)o)->Typespec();
    return nullptr;
}
static const typespec* actualOf(const BaseClass* o) {
    const ref_typespec* rt = tsRefOf(o);
    return rt ? rt->Actual_typespec() : nullptr;
}
static std::string instOf(const typespec* t) {
    if (!t) return "-";
    const BaseClass* i = t->Instance();
    if (!i) return "<null>";
    char b[400];
    snprintf(b, sizeof b, "%s:%s#%u", kindOf(i).c_str(),
             std::string(i->VpiName()).c_str(), i->UhdmId());
    return b;
}
static const BaseClass* enclosingTf(const BaseClass* o) {
    for (const BaseClass* p = o->VpiParent(); p; p = p->VpiParent())
        if (p->UhdmType() == uhdmfunction || p->UhdmType() == uhdmtask) return p;
    return nullptr;
}
static std::string ownScope(const BaseClass* o) {
    for (const BaseClass* p = o->VpiParent(); p; p = p->VpiParent()) {
        UHDM_OBJECT_TYPE t = p->UhdmType();
        if (t == uhdmpackage || t == uhdmclass_defn || t == uhdmmodule_inst ||
            t == uhdminterface_inst || t == uhdmprogram) {
            char b[400];
            snprintf(b, sizeof b, "%s:%s#%u", kindOf(p).c_str(),
                     std::string(p->VpiName()).c_str(), p->UhdmId());
            return b;
        }
    }
    return "<none>";
}

int main(int argc, char** argv) {
    if (argc < 2) { fprintf(stderr, "usage: ct183cen <db.uhdm> [--fe] [--utsinst]\n"); return 2; }
    bool fe = false, utsinst = false;
    for (int i = 2; i < argc; i++) {
        if (!strcmp(argv[i], "--fe")) fe = true;
        if (!strcmp(argv[i], "--utsinst")) utsinst = true;
    }
    if (!fe && !utsinst) fe = true;
    Serializer s;
    if (s.Restore(std::string(argv[1])).empty()) { printf("RESTORE_FAIL\n"); return 3; }
    std::vector<std::string> rows;
    for (auto& kv : s.AllObjects()) {
        const BaseClass* o = kv.first;
        if (!o) continue;
        if (fe && o->UhdmType() == uhdmforeach_stmt) {
            auto* fs = (const foreach_stmt*)o;
            const BaseClass* arr = (const BaseClass*)fs->Variable();
            const BaseClass* tf = enclosingTf(o);
            std::string lv;
            if (auto* lvs = fs->VpiLoopVars())
                for (auto* v : *lvs) {
                    if (!lv.empty()) lv += ",";
                    lv += kindOf(v) + "(" + std::string(v->VpiName()) + ")|" +
                          face(actualOf(v));
                }
            if (lv.empty()) lv = "-";
            char b[4000];
            snprintf(b, sizeof b,
                     "FE\t%u:%u\t%s:%s\t%s\tARR=%s\tARRTS=%s\tINST=%s\tLV=%s",
                     o->VpiLineNo(), (unsigned)o->VpiColumnNo(),
                     tf ? kindOf(tf).c_str() : "-",
                     tf ? std::string(tf->VpiName()).c_str() : "-",
                     ownScope(o).c_str(), face(arr).c_str(),
                     face(actualOf(arr)).c_str(), instOf(actualOf(arr)).c_str(),
                     lv.c_str());
            rows.push_back(b);
        }
        if (utsinst && o->UhdmType() == uhdmunsupported_typespec) {
            char b[900];
            snprintf(b, sizeof b, "UTS\t%s\tINST=%s\t%s", face(o).c_str(),
                     instOf((const typespec*)o).c_str(), ownScope(o).c_str());
            rows.push_back(b);
        }
    }
    std::sort(rows.begin(), rows.end());
    for (auto& r : rows) printf("%s\n", r.c_str());
    return 0;
}
