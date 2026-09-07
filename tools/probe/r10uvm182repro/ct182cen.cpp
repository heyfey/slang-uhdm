// r10uvm182 — THE FAMILY CENSUS.  MEASUREMENT ONLY; `uhdm-cmp` is the judge.
// LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
//
// Enumerates every `ref_obj` that is an ELEMENT of a `hier_path` (its
// `VpiParent` is the path and it appears in `Path_elems`) and prints one row
// per element:
//
//   <file>|<line>:<col>-<endline>:<endcol>|<hier_path name>|<index>/<n>|<name>
//        |ACT=<actual kind>(<actual name>)@<actual line>|<extra>
//
// where <extra> for a func_call / method_func_call actual carries the fields a
// generated `Compare` reads on it: VpiName, whether it has a `Function`, and
// the size of its `Tf_call_args`.
//
// The FILE is inherited from the nearest ANCESTOR that has one — our own
// `hier_path`s carry an EMPTY VpiFile (buvm14 §7's measured census trap) — and
// the DEF/ELAB VIEW is deliberately kept OUT of the key, because the two
// producers label the same object's view differently (buvm14 again); the copies
// land in one bucket and the MULTISET join separates them by CONTENT.
//
// build: g++ -O2 -std=c++17 ct182cen.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct182cen
// usage: ct182cen <db.uhdm>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <algorithm>
#include <cstdio>
#include <string>
#include <vector>

using namespace UHDM;

static std::string fileOf(const BaseClass* o) {
    for (const BaseClass* p = o; p; p = p->VpiParent()) {
        std::string f(p->VpiFile());
        if (!f.empty()) {
            size_t sl = f.find_last_of('/');
            return sl == std::string::npos ? f : f.substr(sl + 1);
        }
    }
    return "<nofile>";
}

// The LISTING an object lives in — the chain of enclosing package / class /
// module / interface names, outermost last.  This is what separates a HOME
// listing (`uvm_pkg`) from a wildcard-import CLONE listing (`adpcm_pkg`), and
// the two are distinguished by real structure the judge can see (each listing
// is reached through its own package object), NOT by the DEF/ELAB view, which
// stays out of every key here (buvm14 §7).
static std::string listingOf(const BaseClass* o) {
    std::string s;
    for (const BaseClass* p = o->VpiParent(); p; p = p->VpiParent()) {
        UHDM_OBJECT_TYPE t = p->UhdmType();
        if (t == uhdmpackage || t == uhdmclass_defn || t == uhdmmodule_inst ||
            t == uhdminterface_inst || t == uhdmdesign) {
            if (!s.empty()) s += "/";
            s += std::string(UhdmName(t)) + ":" + std::string(p->VpiName());
        }
    }
    return s.empty() ? "-" : s;
}

int main(int argc, char** argv) {
    if (argc < 2) { fprintf(stderr, "usage: ct182cen <db.uhdm>\n"); return 2; }
    Serializer s;
    if (s.Restore(std::string(argv[1])).empty()) { printf("RESTORE_FAIL\n"); return 3; }
    std::vector<std::string> rows;
    for (auto& kv : s.AllObjects()) {
        const BaseClass* o = kv.first;
        if (!o || o->UhdmType() != uhdmhier_path) continue;
        const hier_path* hp = (const hier_path*)o;
        const VectorOfany* v = hp->Path_elems();
        if (!v) continue;
        const std::string hn(hp->VpiName());
        const std::string file = fileOf(hp);
        for (size_t i = 0; i < v->size(); ++i) {
            const any* e = v->at(i);
            if (!e) { rows.push_back(file + "|" + hn + "|NULLELEM"); continue; }
            const ref_obj* r = any_cast<const ref_obj*>(e);
            std::string act = "-";
            std::string extra = "-";
            if (r) {
                const any* a = r->Actual_group();
                if (a) {
                    act = std::string(UhdmName(a->UhdmType())) + "(" +
                          std::string(a->VpiName()) + ")@" +
                          std::to_string(a->VpiLineNo()) + ":" +
                          std::to_string((unsigned)a->VpiColumnNo());
                    if (const func_call* fc = any_cast<const func_call*>(a)) {
                        extra = "FN=" + std::string(fc->Function() ? "yes" : "no") +
                                ",ARGS=" +
                                std::to_string(fc->Tf_call_args()
                                                   ? fc->Tf_call_args()->size() : 0) +
                                ",PARENT=" +
                                (fc->VpiParent()
                                     ? std::string(UhdmName(fc->VpiParent()->UhdmType()))
                                     : std::string("none"));
                    }
                    else if (const method_func_call* mc =
                                 any_cast<const method_func_call*>(a)) {
                        extra = "FN=" + std::string(mc->Function() ? "yes" : "no") +
                                ",ARGS=" +
                                std::to_string(mc->Tf_call_args()
                                                   ? mc->Tf_call_args()->size() : 0) +
                                ",PARENT=" +
                                (mc->VpiParent()
                                     ? std::string(UhdmName(mc->VpiParent()->UhdmType()))
                                     : std::string("none"));
                    }
                }
            }
            char b[2400];
            snprintf(b, sizeof b, "%s|%u:%u-%u:%u|%s|%zu/%zu|%s|%s|ACT=%s|%s|IN=%s",
                     file.c_str(), e->VpiLineNo(), (unsigned)e->VpiColumnNo(),
                     e->VpiEndLineNo(), (unsigned)e->VpiEndColumnNo(),
                     hn.c_str(), i, v->size(),
                     std::string(UhdmName(e->UhdmType())).c_str(),
                     std::string(e->VpiName()).c_str(), act.c_str(), extra.c_str(),
                     listingOf(hp).c_str());
            rows.push_back(b);
        }
    }
    std::sort(rows.begin(), rows.end());
    for (auto& r : rows) printf("%s\n", r.c_str());
    // SECTION 2 — every `func_call` whose VpiParent is a `hier_path`, with
    // whether ANY ref_obj's `Actual_group` lands on it.  An UNREFERENCED one is
    // reachable only through the dump's whole-object tail, which the judge
    // never walks (RESUME.md §9) — so this section exists to say out loud how
    // many such orphans each producer mints, and to keep the whole-dump
    // attribution honest about them.
    {
        std::vector<const BaseClass*> refd;
        for (auto& kv : s.AllObjects()) {
            const BaseClass* o = kv.first;
            if (!o) continue;
            if (const ref_obj* r = any_cast<const ref_obj*>(o))
                if (const any* a = r->Actual_group()) refd.push_back(a);
        }
        std::vector<std::string> frows;
        for (auto& kv : s.AllObjects()) {
            const BaseClass* o = kv.first;
            if (!o || o->UhdmType() != uhdmfunc_call) continue;
            const BaseClass* p = o->VpiParent();
            if (!p || p->UhdmType() != uhdmhier_path) continue;
            bool used = std::find(refd.begin(), refd.end(), o) != refd.end();
            frows.push_back(std::string("FC|") + fileOf(o) + "|" +
                            std::string(p->VpiName()) + "|" +
                            std::string(o->VpiName()) + "|" +
                            (used ? "REFERENCED" : "ORPHAN") + "|IN=" +
                            listingOf(p));
        }
        std::sort(frows.begin(), frows.end());
        for (auto& r : frows) printf("%s\n", r.c_str());
        fprintf(stderr, "-- func_call-under-hier_path=%zu\n", frows.size());
    }
    fprintf(stderr, "-- rows=%zu\n", rows.size());
    return 0;
}
