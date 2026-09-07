// r10uvm198 — THE DECLARATION-TYPESPEC CENSUS.  MEASUREMENT ONLY; the official
// `~/git-repos/UHDM/build/bin/uhdm-cmp` is the sole judge.  LHS is ALWAYS
// golden (Surelog), RHS is ALWAYS ours.
//
// One row per VARIABLE DECLARATION of every listing scope in the database — a
// task/function's own `vpiVariables`, and every begin / named_begin / fork arm
// — carrying ONLY WHAT THE JUDGE READS on the declaration's typespec edge:
//
//   CEN|<tag>|<scope>|<idx>|<var kind>|<var name>|TS=<ts kind>:<ts name>:INST=<instance>
//
// The typespec's SPAN and VpiFile are NOT in the payload: `typespec::Compare`
// reads VpiType / VpiName / Typedef_alias / Instance and never a span
// (RESUME §9), so a span in the key would manufacture differences the judge
// cannot see.  They are printed on a separate DUMP-ONLY row that the scorer
// drops:
//
//   SPAN|<tag>|<scope>|<idx>|<var name>|<ts span>
//
// The IO half of the same question (§ classScopedTdImportCopyUnsupported36's
// own population) is emitted too, so this pass can prove it moved NOTHING
// there:
//
//   IO|<tag>|<scope>|<idx>|<io name>|TS=<ts kind>:<ts name>:INST=<instance>
//
// `<scope>` carries the OWNING package / class / module chain, because a
// wildcard-import CLONE's subroutine and its HOME have the same name and the
// same span and would otherwise collide on one key (r10uvm195's note).
//
// build: g++ -O2 -std=c++17 ct198cen.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct198cen
// usage: ct198cen <db.uhdm> <tag>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <algorithm>
#include <cstdio>
#include <string>
#include <vector>

using namespace UHDM;

static std::string span(const BaseClass* o) {
    char b[80];
    snprintf(b, sizeof b, "%u:%u-%u:%u", o->VpiLineNo(),
             (unsigned)o->VpiColumnNo(), o->VpiEndLineNo(),
             (unsigned)o->VpiEndColumnNo());
    return b;
}
static std::string home(const BaseClass* o) {
    std::string s;
    int g = 0;
    for (const BaseClass* p = o->VpiParent(); p && g < 40;
         p = p->VpiParent(), ++g) {
        const UHDM_OBJECT_TYPE t = p->UhdmType();
        if (t != uhdmpackage && t != uhdmclass_defn && t != uhdmmodule_inst)
            continue;
        s += "<";
        s += std::string(UhdmName(t));
        s += ":";
        s += std::string(p->VpiName());
    }
    return s;
}
static std::string scopeKey(const BaseClass* o) {
    std::string s(UhdmName(o->UhdmType()));
    s += ":";
    s += std::string(o->VpiName());
    s += "@";
    s += span(o);
    s += home(o);
    return s;
}
static const typespec* actual(const ref_typespec* rt) {
    return rt ? rt->Actual_typespec() : nullptr;
}
// what `typespec::Compare` can see on this edge, and nothing else
static std::string tsPayload(const ref_typespec* rt) {
    const typespec* a = actual(rt);
    if (!a) return "TS=<null>";
    std::string s = "TS=";
    s += std::string(UhdmName(a->UhdmType()));
    s += ":";
    s += std::string(a->VpiName());
    s += ":INST=";
    const instance* in = a->Instance();
    if (!in) s += "-";
    else {
        s += std::string(UhdmName(in->UhdmType()));
        s += ":";
        s += std::string(in->VpiName());
    }
    if (a->Typedef_alias()) {
        const typespec* al = a->Typedef_alias()->Actual_typespec();
        s += ":ALIAS=";
        s += al ? std::string(UhdmName(al->UhdmType())) + ":" +
                      std::string(al->VpiName())
                : std::string("<null>");
    }
    return s;
}
static std::string tsSpan(const ref_typespec* rt) {
    const typespec* a = actual(rt);
    return a ? span(a) : std::string("-");
}

int main(int argc, char** argv) {
    if (argc < 3) { fprintf(stderr, "usage: ct198cen <db.uhdm> <tag>\n"); return 2; }
    Serializer S;
    if (S.Restore(std::string(argv[1])).empty()) { printf("RESTORE_FAIL\n"); return 3; }
    const char* tag = argv[2];
    std::vector<std::string> rows;
    for (auto& kv : S.AllObjects()) {
        const BaseClass* X = kv.first;
        if (!X) continue;
        const VectorOfvariables* vars = nullptr;
        const VectorOfio_decl* ios = nullptr;
        switch (X->UhdmType()) {
            case uhdmtask:
                vars = ((const task*)X)->Variables();
                ios = ((const task*)X)->Io_decls();
                break;
            case uhdmfunction:
                vars = ((const function*)X)->Variables();
                ios = ((const function*)X)->Io_decls();
                break;
            case uhdmbegin: vars = ((const begin*)X)->Variables(); break;
            case uhdmnamed_begin: vars = ((const named_begin*)X)->Variables(); break;
            case uhdmfork_stmt: vars = ((const fork_stmt*)X)->Variables(); break;
            case uhdmnamed_fork: vars = ((const named_fork*)X)->Variables(); break;
            default: continue;
        }
        const std::string sk = scopeKey(X);
        if (vars)
            for (size_t i = 0; i < vars->size(); ++i) {
                const variables* v = (*vars)[i];
                if (!v) {
                    rows.push_back(std::string("CEN|") + tag + "|" + sk + "|" +
                                   std::to_string(i) + "|<null>||TS=<novar>");
                    continue;
                }
                rows.push_back(std::string("CEN|") + tag + "|" + sk + "|" +
                               std::to_string(i) + "|" +
                               std::string(UhdmName(v->UhdmType())) + "|" +
                               std::string(v->VpiName()) + "|" +
                               tsPayload(v->Typespec()));
                rows.push_back(std::string("SPAN|") + tag + "|" + sk + "|" +
                               std::to_string(i) + "|" +
                               std::string(v->VpiName()) + "|" +
                               tsSpan(v->Typespec()));
            }
        if (ios)
            for (size_t i = 0; i < ios->size(); ++i) {
                const io_decl* d = (*ios)[i];
                if (!d) continue;
                rows.push_back(std::string("IO|") + tag + "|" + sk + "|" +
                               std::to_string(i) + "|" +
                               std::string(d->VpiName()) + "|" +
                               tsPayload(d->Typespec()));
            }
    }
    std::sort(rows.begin(), rows.end());
    for (auto& r : rows) printf("%s\n", r.c_str());
    return 0;
}
