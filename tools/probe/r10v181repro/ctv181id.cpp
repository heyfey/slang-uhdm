// r10v181 — THE IDENTITY instrument.  MEASUREMENT ONLY; `uhdm-cmp` judges.
//
// `ct181grid.cpp` prints a bind TARGET as `kind:name@line:col`, which cannot
// tell the SHARED law cloneLoopVarShared37 object from a second object minted at the
// same source position with the same kind and name.  The pass's whole claim is
// that a body reference binds the object the foreach's own `VpiLoopVars`
// `ref_var` already points at, so that distinction is the claim.
//
// For every `foreach_stmt` under a task_func this prints one row per BODY
// reference that names one of the loop's variables:
//
//   <tag> <pkg>|<tf>|<EMPTYTF|HASLOCALS>|fe@<L>:<C>|<var> <ref-kind>@<L>:<C>
//        = SHARED | LISTING-REF | OTHER:<kind>:<name>@<L>:<C> | BARE
//
// SHARED       vpiActual is the SAME object as the loop listing's
//              `ref_var`'s vpiActual -- the law cloneLoopVarShared37 object.
// LISTING-REF  vpiActual is the listing `ref_var` itself (one hop short).
// OTHER        a different object entirely (a MINTED twin shows up here, and
//              so does an outer loop's object in a shadowing nest).
// BARE         null.
//
// No object ids and no file paths are printed, so a golden row and a slang row
// are comparable byte for byte and the rows are order-blind once sorted.
//
// build: g++ -O2 -std=c++17 ctv181id.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ctv181id
// usage: ctv181id <db.uhdm> <tag>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <algorithm>
#include <cstdio>
#include <map>
#include <string>
#include <vector>

using namespace UHDM;

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
static std::string pos(const BaseClass* o) {
    char b[64];
    snprintf(b, sizeof b, "@%u:%u", o->VpiLineNo(), (unsigned)o->VpiColumnNo());
    return b;
}
static std::string face(const BaseClass* o) {
    if (!o) return "?";
    return std::string(UhdmName(o->UhdmType())) + ":" + std::string(o->VpiName()) +
           pos(o);
}

int main(int argc, char** argv) {
    if (argc < 3) { fprintf(stderr, "usage: ctv181id <db> <tag>\n"); return 2; }
    const std::string tag = argv[2];
    Serializer S;
    if (S.Restore(std::string(argv[1])).empty()) { printf("RESTORE_FAIL\n"); return 3; }

    // Deterministic walk order.
    std::vector<const BaseClass*> objs;
    for (auto& kv : S.AllObjects())
        if (kv.first) objs.push_back(kv.first);
    std::sort(objs.begin(), objs.end(),
              [](const BaseClass* a, const BaseClass* b) {
                  return a->UhdmId() < b->UhdmId();
              });

    std::vector<std::string> rows;
    for (const BaseClass* o : objs) {
        if (!isRef(o)) continue;
        const std::string nm(o->VpiName());
        if (nm.empty()) continue;
        // Find the innermost enclosing foreach that LISTS this name, and the
        // owning task_func / package.
        const foreach_stmt* fe = nullptr;
        const ref_var* lv = nullptr;
        const task_func* tf = nullptr;
        std::string pkg = "-";
        bool isListing = false;
        for (const BaseClass* p = o->VpiParent(); p; p = p->VpiParent()) {
            if (!fe && p->UhdmType() == uhdmforeach_stmt) {
                auto* lvs = ((const foreach_stmt*)p)->VpiLoopVars();
                if (lvs)
                    for (auto* v : *lvs)
                        if (v && v->UhdmType() == uhdmref_var &&
                            v->VpiName() == nm) {
                            fe = (const foreach_stmt*)p;
                            lv = (const ref_var*)v;
                            if (v == o) isListing = true;
                        }
            }
            if (!tf && (p->UhdmType() == uhdmfunction || p->UhdmType() == uhdmtask))
                tf = (const task_func*)p;
            if (p->UhdmType() == uhdmpackage) { pkg = std::string(p->VpiName()); break; }
            if (p->UhdmType() == uhdmmodule_inst) {
                pkg = "MOD:" + std::string(p->VpiName());
                break;
            }
        }
        if (!fe || !lv) continue;
        if (isListing) continue;          // the listing entry is not a body ref
        bool io = tf && tf->Io_decls() && !tf->Io_decls()->empty();
        bool vs = tf && tf->Variables() && !tf->Variables()->empty();
        const BaseClass* shared = lv->Actual_group();
        const BaseClass* act = actualOf(o);
        std::string verdict;
        if (!act) verdict = "BARE";
        else if (act == shared) verdict = "SHARED";
        else if (act == (const BaseClass*)lv) verdict = "LISTING-REF";
        else verdict = "OTHER:" + face(act);
        rows.push_back(tag + " " + pkg + "|" +
                       (tf ? std::string(tf->VpiName()) : "-") + "|" +
                       ((tf && !io && !vs) ? "EMPTYTF" : "HASLOCALS") + "|fe" +
                       pos(fe) + "|" + nm + " " +
                       std::string(UhdmName(o->UhdmType())) + pos(o) + " = " +
                       verdict);
    }
    std::sort(rows.begin(), rows.end());
    for (auto& r : rows) printf("%s\n", r.c_str());
    // A summary the eye can read.
    std::map<std::string, int> tally;
    for (auto& r : rows) {
        auto p = r.rfind(" = ");
        std::string v = r.substr(p + 3);
        if (v.rfind("OTHER:", 0) == 0) v = "OTHER";
        tally[v]++;
    }
    printf("# %s TALLY", tag.c_str());
    for (auto& kv : tally) printf(" %s=%d", kv.first.c_str(), kv.second);
    printf(" rows=%zu\n", rows.size());
    return 0;
}
