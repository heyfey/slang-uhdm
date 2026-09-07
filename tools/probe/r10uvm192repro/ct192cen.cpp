// r10uvm192 — THE CALL-BINDING CENSUS.  MEASUREMENT ONLY; the official
// `~/git-repos/UHDM/build/bin/uhdm-cmp` is the sole judge.  LHS is ALWAYS
// golden (Surelog), RHS is ALWAYS ours.
//
// The r10uvm190 R0 head is a `func_call::Function` singular edge: golden binds
// a class-QUALIFIED call to the PACKAGE's own qualified listing copy of the
// method, we bind it to the CLASS's bare copy.  Both copies exist on both
// sides (the listings agree index for index — `ct192own` STEP 3), so the law is
// a BINDING law, not a listing law.  This census emits one row per CALL, keyed
// on the matrix the law is written in:
//
//   CALL  <file-independent span> | <call kind> | <call VpiName> |
//         <caller scope kind> | <caller scope name> |
//         <bound subroutine: kind, VpiName, parent kind, parent name>
//
// The caller-scope columns are what separate the two arms; the bound-name
// column is the judge-visible payload (`BaseClass::Compare` reads VpiName).
// The DEF/ELAB view is deliberately KEPT OUT OF THE KEY (RESUME.md §9: the two
// producers label it differently) — instead every row carries the size of its
// top-level listing so the two views of a package never merge into one
// multiset (the recorded listcheck lesson).
//
// Section SUB emits one row per SUBROUTINE object so the listing multiplicity
// itself is measurable: kind | VpiName | parent kind | parent name | span.
//
// build: g++ -O2 -std=c++17 ct192cen.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct192cen
// usage: ct192cen <db.uhdm> <tag>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <cstdio>
#include <cstring>
#include <string>
#include <algorithm>
#include <vector>

using namespace UHDM;

static const design* topDesign(Serializer& s) {
    for (auto& kv : s.AllObjects())
        if (kv.first && kv.first->UhdmType() == uhdmdesign)
            return (const design*)kv.first;
    return nullptr;
}
static bool isSub(const BaseClass* o) {
    return o && (o->UhdmType() == uhdmfunction || o->UhdmType() == uhdmtask);
}
static bool isCall(const BaseClass* o) {
    if (!o) return false;
    const UHDM_OBJECT_TYPE t = o->UhdmType();
    return t == uhdmfunc_call || t == uhdmtask_call || t == uhdmmethod_func_call ||
           t == uhdmmethod_task_call;
}
// The nearest enclosing named scope of `o`: a class_defn, a package, a module
// or a subroutine.  Reported as kind + name so the arms are separable.
static void enclosing(const BaseClass* o, std::string& kind, std::string& name,
                      std::string& subKind, std::string& subName) {
    kind = "-"; name = "-"; subKind = "-"; subName = "-";
    int g = 0;
    for (const BaseClass* p = o->VpiParent(); p && g < 128; p = p->VpiParent(), ++g) {
        const UHDM_OBJECT_TYPE t = p->UhdmType();
        if (subKind == "-" && isSub(p)) {
            subKind = UhdmName(t);
            subName = p->VpiName();
        }
        if (t == uhdmclass_defn || t == uhdmpackage || t == uhdmmodule_inst ||
            t == uhdminterface_inst || t == uhdmprogram) {
            kind = UhdmName(t);
            name = p->VpiName();
            return;
        }
    }
}
static const BaseClass* boundOf(const BaseClass* o) {
    if (const func_call* f = any_cast<const func_call*>(o)) return f->Function();
    if (const task_call* f = any_cast<const task_call*>(o)) return f->Task();
    if (const method_func_call* f = any_cast<const method_func_call*>(o)) return f->Function();
    if (const method_task_call* f = any_cast<const method_task_call*>(o)) return f->Task();
    return nullptr;
}
static std::string face(const BaseClass* o) {
    if (!o) return "<null>|-|-|-";
    std::string pk = "-", pn = "-";
    if (const BaseClass* p = o->VpiParent()) { pk = UhdmName(p->UhdmType()); pn = p->VpiName(); }
    return std::string(UhdmName(o->UhdmType())) + "|" + std::string(o->VpiName()) + "|" +
           pk + "|" + pn;
}
// How big is the top-level listing this object hangs under?  This keeps the
// DEF and ELAB copies of one package in SEPARATE multisets without putting the
// view label (which the two producers spell differently) into the key.
static unsigned topListingSize(const BaseClass* o) {
    const BaseClass* top = o;
    for (const BaseClass* p = o; p; p = p->VpiParent())
        if (p->UhdmType() == uhdmpackage || p->UhdmType() == uhdmmodule_inst) top = p;
    if (top == o) return 0;
    auto tup = top->GetByVpiType(vpiTaskFunc);
    const std::vector<const BaseClass*>* v = std::get<2>(tup);
    return v ? (unsigned)v->size() : 0;
}

int main(int argc, char** argv) {
    if (argc < 3) { fprintf(stderr, "usage: ct192cen <db.uhdm> <tag>\n"); return 2; }
    const char* tag = argv[2];
    Serializer s;
    if (s.Restore(std::string(argv[1])).empty()) { printf("RESTORE_FAIL %s\n", tag); return 3; }
    if (!topDesign(s)) { printf("NO_DESIGN %s\n", tag); return 3; }

    std::vector<std::string> calls, subs;
    for (auto& kv : s.AllObjects()) {
        const BaseClass* o = kv.first;
        if (!o) continue;
        char b[2400];
        if (isCall(o)) {
            std::string ck, cn, sk, sn;
            enclosing(o, ck, cn, sk, sn);
            const BaseClass* B = boundOf(o);
            // Trailing, NOT part of the key: the chain of parent KINDS from
            // the call up to its enclosing subroutine.  This is what tells the
            // implementer which relations a body walk has to traverse.
            std::string chain;
            int g2 = 0;
            for (const BaseClass* p = o->VpiParent(); p && g2 < 64;
                 p = p->VpiParent(), ++g2) {
                chain += (chain.empty() ? "" : "<");
                chain += UhdmName(p->UhdmType());
                if (isSub(p)) break;
            }
            snprintf(b, sizeof b,
                     "CALL\t%s\t%u:%u-%u:%u\t%s\t%s\t%s\t%s\t%s\t%s\t%u\t%s",
                     tag, o->VpiLineNo(), (unsigned)o->VpiColumnNo(), o->VpiEndLineNo(),
                     (unsigned)o->VpiEndColumnNo(), std::string(UhdmName(o->UhdmType())).c_str(),
                     std::string(o->VpiName()).c_str(), ck.c_str(), cn.c_str(),
                     sk.c_str(), face(B).c_str(), topListingSize(o), chain.c_str());
            calls.push_back(b);
        }
        if (isSub(o)) {
            std::string pk = "-", pn = "-";
            if (const BaseClass* p = o->VpiParent()) {
                pk = UhdmName(p->UhdmType());
                pn = p->VpiName();
            }
            snprintf(b, sizeof b, "SUB\t%s\t%u:%u-%u:%u\t%s\t%s\t%s\t%s\t%u", tag,
                     o->VpiLineNo(), (unsigned)o->VpiColumnNo(), o->VpiEndLineNo(),
                     (unsigned)o->VpiEndColumnNo(), std::string(UhdmName(o->UhdmType())).c_str(),
                     std::string(o->VpiName()).c_str(), pk.c_str(), pn.c_str(),
                     topListingSize(o));
            subs.push_back(b);
        }
    }
    // ---- PRED — THE FENCE, TRANSCRIBED ---------------------------------
    // One row per call § pkgTfBodyCmViewClone192 WOULD re-point in this
    // database, and one WIDE row per call that clears the first two fence
    // terms but finds no entry (the upper bound a wrongly-scoped version of
    // the law could touch).  This is the predictor: run it over PRISTINE
    // databases and it names the mover set before any patched binary exists.
    std::vector<std::string> preds;
    for (auto& kv : s.AllObjects()) {
        const BaseClass* o = kv.first;
        if (!o) continue;
        const bool isF = o->UhdmType() == uhdmfunc_call;
        const bool isT = o->UhdmType() == uhdmtask_call;
        if (!isF && !isT) continue;
        const BaseClass* cur = boundOf(o);
        if (!cur || !cur->VpiParent() ||
            cur->VpiParent()->UhdmType() != uhdmclass_defn)
            continue;
        const std::string cn(o->VpiName());
        if (cn.find("::") == std::string::npos) continue;
        const BaseClass* sub = nullptr;
        const BaseClass* p = o->VpiParent();
        for (int g = 0; p && g < 4096; p = p->VpiParent(), ++g) {
            const UHDM_OBJECT_TYPE k = p->UhdmType();
            if (k == uhdmfunction || k == uhdmtask) { sub = p; break; }
            if (k == uhdmclass_defn || k == uhdmpackage || k == uhdmmodule_inst ||
                k == uhdminterface_inst || k == uhdmprogram || k == uhdmdesign)
                break;
        }
        if (!sub || !sub->VpiParent() || sub->VpiParent()->UhdmType() != uhdmpackage)
            continue;
        const package* pv = (const package*)sub->VpiParent();
        if (!pv->Task_funcs()) continue;
        // THE HOME/IMPORTER SPLIT (production fence 3).  TWO CANDIDATE
        // TERMS are measured side by side, because the uvm-1.2 rows and the
        // arm-C golden disagree about which one is the law:
        //   calleeHome — the class owning the BOUND METHOD is a class of this
        //                package;
        //   callerHome — the class owning the ENCLOSING SUBROUTINE is a class
        //                of this package (a free function counts as home).
        // `callerHome` is the one that separates an import CLONE of another
        // package's body (which keeps the class method) from this package's
        // OWN body (which binds this listing's entry, whatever class the
        // callee belongs to).
        const std::string pvn(pv->VpiName());
        auto classOfPkg = [&](const std::string& cls) {
            if (cls.empty()) return true;
            for (auto& kv2 : s.AllObjects()) {
                const BaseClass* c2 = kv2.first;
                if (!c2 || c2->UhdmType() != uhdmclass_defn) continue;
                if (std::string(c2->VpiName()) != cls) continue;
                for (const BaseClass* p3 = c2->VpiParent(); p3; p3 = p3->VpiParent())
                    if (p3->UhdmType() == uhdmpackage) {
                        if (std::string(p3->VpiName()) == pvn) return true;
                        break;
                    }
            }
            return false;
        };
        const BaseClass* chp0 = cur->VpiParent();
        std::string chp = "-";
        for (const BaseClass* p2 = chp0 ? chp0->VpiParent() : nullptr; p2;
             p2 = p2->VpiParent())
            if (p2->UhdmType() == uhdmpackage) { chp = p2->VpiName(); break; }
        const bool calleeHome = chp == pvn;
        const std::string subn(sub->VpiName());
        const size_t q = subn.find("::");
        const bool callerHome =
            q == std::string::npos ? true : classOfPkg(subn.substr(0, q));
        const bool homeSame = callerHome;
        const BaseClass* tgt = nullptr;
        for (auto* t : *pv->Task_funcs()) {
            if (!t || t == cur || std::string(t->VpiName()) != cn) continue;
            if ((isF && t->UhdmType() == uhdmfunction) ||
                (isT && t->UhdmType() == uhdmtask)) { tgt = t; break; }
        }
        // The row carries THE CALL'S OWN CENSUS KEY verbatim, so the scorer
        // looks golden up on the one cell and never unions the four copies of
        // a call that the two views x the home/importer split produce (RESUME
        // §9: never merge a package's two listings into one multiset).
        std::string ck, cn2, sk, sn;
        enclosing(o, ck, cn2, sk, sn);
        char key[1600];
        snprintf(key, sizeof key, "%u:%u-%u:%u\t%s\t%s\t%s\t%s\t%s\t%u",
                 o->VpiLineNo(), (unsigned)o->VpiColumnNo(), o->VpiEndLineNo(),
                 (unsigned)o->VpiEndColumnNo(),
                 std::string(UhdmName(o->UhdmType())).c_str(), cn.c_str(),
                 ck.c_str(), cn2.c_str(), sk.c_str(), topListingSize(o));
        char b[3200];
        snprintf(b, sizeof b, "PRED\t%s\t%s\t%s\tpkg=%s\thome=%s\tfrom=%s\tto=%s",
                 tag,
                 !homeSame ? "HOME-OTHER" : (tgt ? "MOVE" : "WIDE-NO-ENTRY"),
                 key, pvn.c_str(),
                 homeSame ? "SAME" : "OTHER", face(cur).c_str(),
                 tgt ? face(tgt).c_str() : "-");
        snprintf(b + strlen(b), sizeof b - strlen(b),
                 "\tsub=%s\tcallerHome=%s\tcalleeHome=%s", subn.c_str(),
                 callerHome ? "Y" : "N", calleeHome ? "Y" : "N");
        preds.push_back(b);
    }
    std::sort(calls.begin(), calls.end());
    std::sort(subs.begin(), subs.end());
    std::sort(preds.begin(), preds.end());
    for (auto& r : calls) printf("%s\n", r.c_str());
    for (auto& r : subs) printf("%s\n", r.c_str());
    for (auto& r : preds) printf("%s\n", r.c_str());
    fprintf(stderr, "%s CALLS=%zu SUBS=%zu PRED=%zu\n", tag, calls.size(),
            subs.size(), preds.size());
    return 0;
}
