// r10uvm180 — THE MOVER PREDICTOR.  Reads ONE OF OUR OWN PRISTINE DATABASES
// and answers: will § cloneBodyBareTdAlias180 change this database?
// MEASUREMENT ONLY; no golden is read, so the prediction is made BEFORE the
// patched sweep runs and cannot be back-fitted to it.
//
// THE PREDICATE, in database terms (the emitter's own gate is
// `pkgImportCloneTfs16`, which no database records):
//   a `ref_typespec` reached DOWN a package P's subroutine tree, with no
//   `class_defn` and no other typespec on the path, whose bound typespec is a
//   LAW-S scalar kind and whose `Typedef_alias` target is named `Q::t` with
//   Q != P.  A HOME body's alias target is named `P::t`, so it never counts;
//   only a clone body — whose chain Surelog re-mints against the IMPORTER —
//   can hold another package's qualified listing object here.
//
// build: g++ -O2 -std=c++17 predict180.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o predict180
// usage: predict180 <ours.uhdm>      -> "PREDICT MOVER n=<cells>" or "PREDICT SAME"
#include <uhdm/uhdm.h>
#include <uhdm/UhdmListener.h>
#include <uhdm/vpi_uhdm.h>

#include <cstdio>
#include <set>
#include <string>

using namespace UHDM;

static bool scalarTdKind(UHDM_OBJECT_TYPE t) {
    switch (t) {
        case uhdmlogic_typespec: case uhdmbit_typespec: case uhdmint_typespec:
        case uhdminteger_typespec: case uhdmbyte_typespec:
        case uhdmshort_int_typespec: case uhdmlong_int_typespec: return true;
        default: return false;
    }
}
static const design* topDesign(Serializer& s) {
    for (auto& kv : s.AllObjects())
        if (kv.first && kv.first->UhdmType() == uhdmdesign)
            return (const design*)kv.first;
    return nullptr;
}

class Predict180 final : public UhdmListener {
  public:
    std::set<std::string> hits;  // "P|Q::t" — deduplicated, printed as evidence
    void enterRef_typespec(const ref_typespec* const o) override {
        const typespec* at = o->Actual_typespec();
        if (!at || !scalarTdKind(at->UhdmType())) return;
        const ref_typespec* al = at->Typedef_alias();
        const typespec* tg = al ? al->Actual_typespec() : nullptr;
        if (!tg) return;
        std::string tn(tg->VpiName());
        const size_t q = tn.find("::");
        if (q == std::string::npos) return;
        const auto& cs = getCallstack();
        // the innermost subroutine on the walk's own path, with nothing
        // SHARED between it and the ref (the law's FENCE 2)
        const task_func* tf = nullptr;
        int at_i = -1;
        for (int i = (int)cs.size() - 2; i >= 0; --i) {
            const UHDM_OBJECT_TYPE k = cs[i]->UhdmType();
            if (k == uhdmfunction || k == uhdmtask) {
                tf = (const task_func*)cs[i];
                at_i = i;
                break;
            }
            if (k == uhdmclass_defn || any_cast<const typespec*>(cs[i])) return;
        }
        if (!tf) return;
        // FENCE 3: the subroutine's RETURN VARIABLE keeps the home's target
        if (at_i + 1 < (int)cs.size() && cs[at_i + 1] == (const any*)tf->Return())
            return;
        // the owning package is the SUBROUTINE's own, by VpiParent — never the
        // package the walk started in.  A clone body's `func_call` -> Function()
        // edge can carry the walk into the HOME body, where a qualified target
        // is correct; keying on the walk's origin would report that as a cell.
        const BaseClass* pkg = nullptr;
        for (const BaseClass* p = tf; p; p = p->VpiParent())
            if (p->UhdmType() == uhdmpackage) pkg = p;
        if (!pkg) return;
        std::string pn(pkg->VpiName());
        if (pn == tn.substr(0, q)) return;   // the HOME body
        hits.insert(pn + "|" + tn);
    }
};

int main(int argc, char** argv) {
    if (argc < 2) { fprintf(stderr, "usage: predict180 <ours.uhdm>\n"); return 2; }
    Serializer s;
    if (s.Restore(std::string(argv[1])).empty()) { printf("PREDICT RESTORE_FAIL\n"); return 3; }
    const design* d = topDesign(s);
    if (!d) { printf("PREDICT NO_DESIGN\n"); return 3; }
    Predict180 p;
    p.listenDesign(d);
    if (p.hits.empty()) { printf("PREDICT SAME\n"); return 0; }
    printf("PREDICT MOVER n=%zu\n", p.hits.size());
    for (auto& h : p.hits) printf("  %s\n", h.c_str());
    return 0;
}
