// r10uvm167 — THE CALL-ARGUMENT-VECTOR CENSUS.  MEASUREMENT ONLY; the official
// `~/git-repos/UHDM/build/bin/uhdm-cmp` is the sole judge; this tool only
// reports.  LHS is ALWAYS golden (Surelog), RHS is ALWAYS ours.
//
// THE HEAD this pass owns is a `tf_call::Tf_call_args` VECTOR SIZE mismatch
// (`~/git-repos/UHDM/build/generated/src/tf_call.cpp:95`, the VECTOR
// `SafeCompare` at `BaseClass.h:201-208`), so the census key must carry the
// SIZE and the per-slot identity of the argument vector and nothing that the
// judge does not read.
//
// FAMILIES
//   CALL| one row per tf_call of ANY subtype (func_call / task_call /
//         method_func_call / method_task_call / sys_func_call / sys_task_call /
//         Surelog's `constant` ctor forms are NOT tf_calls and do not appear),
//         keyed by  KIND x NAME x SPAN x HOME  with the value N=<vector size>
//         and SPELL=<prefix kind> (the receiver face: none / ref / const /
//         underhier).  This is the cell the head lives in.
//   ARG|  one row per ARGUMENT SLOT of every such call, keyed by the same call
//         key plus the slot INDEX, valued by the slot's KIND, its own SPAN and
//         its DECOMPILE (which uhdm-cmp DOES read — RESUME §9).  A size move is
//         only TOWARD if the surviving slots are golden's slots.
//   OBJ|  a whole-database depth-keyed identity census (KIND x NAME x SPAN x
//         HOME), so collateral anywhere else in the database is visible even
//         when no call moved.
//
// The DEF-view and ELAB-view databases must NEVER be merged into one multiset
// (r10uvm166 §6): the driver keys every row with the RUN tag it was built in.
//
// build: g++ -O2 -std=c++17 ct167cen.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct167cen
//   PRED| the A-PRIORI PREDICTOR (`--pred`), which reads OUR databases ALONE and
//         needs no golden at all.  A call whose invocation syntax IS reachable
//         has ALREADY been trimmed to its written actuals by § writtenCallArgs16
//         since the ApbSlave probe, so a TRAILING RUN of vpiArguments whose OWN
//         SPAN lies OUTSIDE the call's span is the fingerprint of the defect
//         this pass fixes: those objects are the CALLEE's formal defaults,
//         cloned from the declaration.  The row carries the length of that run
//         (`OUT=k`), so the prediction is a NAMED LIST of calls, made before the
//         patched binary is looked at.
//
// usage: ct167cen <db.uhdm> <tag> [--nospan] [--noobj] [--pred]
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
static bool PRED = false;

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
// The enclosing NAMED containers, outermost last.  Deliberately NAME-based and
// not pointer-based: the two databases are different arenas.
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
static std::string decOf(const BaseClass* o) {
    if (const expr* e = any_cast<const expr*>(o)) {
        std::string d(e->VpiDecompile());
        if (!d.empty()) {
            // keep the census line printable and one-per-line
            for (auto& c : d)
                if (c == '\n' || c == '\r' || c == '|') c = ' ';
            if (d.size() > 90) d = d.substr(0, 90) + "...";
            return d;
        }
    }
    return "-";
}
static const std::vector<any*>* argsOf(const BaseClass* o) {
    if (const tf_call* t = any_cast<const tf_call*>(o)) return t->Tf_call_args();
    return nullptr;
}
static std::string spellOf(const BaseClass* o) {
    const BaseClass* pfx = nullptr;
    if (const method_func_call* m = any_cast<const method_func_call*>(o)) pfx = m->Prefix();
    else if (const method_task_call* m = any_cast<const method_task_call*>(o)) pfx = m->Prefix();
    if (!pfx) return "none";
    return kindOf(pfx);
}

int main(int argc, char** argv) {
    if (argc < 3) {
        fprintf(stderr, "usage: ct167cen <db.uhdm> <tag> [--nospan] [--noobj]\n");
        return 2;
    }
    for (int i = 3; i < argc; ++i) {
        if (!strcmp(argv[i], "--nospan")) NOSPAN = true;
        if (!strcmp(argv[i], "--noobj")) NOOBJ = true;
        if (!strcmp(argv[i], "--pred")) { PRED = true; NOOBJ = true; }
    }
    Serializer s;
    if (s.Restore(std::string(argv[1])).empty()) {
        fprintf(stderr, "RESTORE_FAIL %s\n", argv[1]);
        return 3;
    }
    const std::string tag(argv[2]);
    std::vector<std::string> out;
    char b[8192];
    for (auto& kv : s.AllObjects()) {
        const BaseClass* o = kv.first;
        if (!o) continue;
        if (any_cast<const tf_call*>(o)) {
            const std::vector<any*>* a = argsOf(o);
            const size_t n = a ? a->size() : 0;
            if (PRED) {
                // A METHOD call's own span is the METHOD NAME alone, so
                // "outside the call" is useless; the containment test is the
                // CALLER'S SUBROUTINE.  A defaulted formal's expression is
                // cloned from the CALLEE's declaration and therefore lands in a
                // different file, or outside the caller's line range — which no
                // WRITTEN actual ever does.
                const BaseClass* fn = nullptr;
                for (const BaseClass* p = o->VpiParent(); p; p = p->VpiParent())
                    if (p->UhdmType() == uhdmfunction || p->UhdmType() == uhdmtask) {
                        fn = p;
                        break;
                    }
                size_t k = 0;
                if (fn && fn->VpiLineNo()) {
                    const std::string ff(fn->VpiFile());
                    for (size_t i = n; i-- > 0;) {
                        const BaseClass* x = a->at(i);
                        if (!x || x->VpiLineNo() == 0) break;  // loc-less: not a clone
                        const std::string xf(x->VpiFile());
                        const bool inside =
                            (xf.empty() || ff.empty() || xf == ff) &&
                            x->VpiLineNo() >= fn->VpiLineNo();
                        if (inside) break;
                        ++k;
                    }
                }
                // FGN counts EVERY foreign argument, not just the trailing run,
                // so a MIDDLE default reached through named association (which
                // no trailing run can see) is still visible.  OUT is the
                // high-confidence predictor; FGN is its superset.
                size_t fgn = 0;
                if (fn && fn->VpiLineNo()) {
                    const std::string ff(fn->VpiFile());
                    for (size_t i = 0; i < n; ++i) {
                        const BaseClass* x = a->at(i);
                        if (!x || x->VpiLineNo() == 0) continue;
                        const std::string xf(x->VpiFile());
                        if (!((xf.empty() || ff.empty() || xf == ff) &&
                              x->VpiLineNo() >= fn->VpiLineNo()))
                            ++fgn;
                    }
                }
                if (k || fgn) {
                    snprintf(b, sizeof b, "PRED|%s|%s|%s|%s|%s|N=%zu|OUT=%zu|FGN=%zu",
                             tag.c_str(), kindOf(o).c_str(),
                             std::string(o->VpiName()).c_str(), spanOf(o).c_str(),
                             homeChain(o).c_str(), n, k, fgn);
                    out.push_back(b);
                }
                continue;
            }
            snprintf(b, sizeof b, "CALL|%s|%s|%s|%s|%s|SPELL=%s|N=%zu", tag.c_str(),
                     kindOf(o).c_str(), std::string(o->VpiName()).c_str(),
                     spanOf(o).c_str(), homeChain(o).c_str(), spellOf(o).c_str(), n);
            out.push_back(b);
            for (size_t i = 0; a && i < a->size(); ++i) {
                const BaseClass* x = a->at(i);
                snprintf(b, sizeof b, "ARG|%s|%s|%s|%s|%s|#%zu|%s|%s|%s", tag.c_str(),
                         kindOf(o).c_str(), std::string(o->VpiName()).c_str(),
                         spanOf(o).c_str(), homeChain(o).c_str(), i,
                         kindOf(x).c_str(), spanOf(x).c_str(), decOf(x).c_str());
                out.push_back(b);
            }
        }
        if (!NOOBJ) {
            snprintf(b, sizeof b, "OBJ|%s|%s|%s|%s|%s", tag.c_str(), kindOf(o).c_str(),
                     std::string(o->VpiName()).c_str(), spanOf(o).c_str(),
                     homeChain(o).c_str());
            out.push_back(b);
        }
    }
    std::sort(out.begin(), out.end());
    for (auto& l : out) printf("%s\n", l.c_str());
    return 0;
}
