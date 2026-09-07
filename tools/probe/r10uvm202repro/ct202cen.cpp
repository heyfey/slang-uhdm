// r10uvm202 — THE DECLARATION-TYPESPEC + CLASS_TYPESPEC CENSUS.
//
// MEASUREMENT ONLY; the official `~/git-repos/UHDM/build/bin/uhdm-cmp` is the
// sole judge.  LHS is ALWAYS golden (Surelog), RHS is ALWAYS ours.
//
// This is r10uvm198repro/ct198cen.cpp — the same CEN|/SPAN|/IO| rows, byte for
// byte the same key construction, so the two censuses are directly comparable —
// with the rows THIS pass's two questions need added:
//
//   CLS|<tag>|<ts name>|<class_defn kind:name>|ALIAS=<alias ts name>|OWNSPAN=<Y|N>
//       one row per `class_typespec` in the database.  `OWNSPAN` is the
//       SPAN-vs-OWN-DECLARATION question (4b): a class_typespec whose
//       vpiName ends in `::<X>` (or is bare `<X>`) but whose span does NOT
//       cover a `typedef ... <X>;` is a SHARED-AND-RENAMED object.  The test
//       is made without the source: the object's own name tail is compared
//       against the name tail of EVERY class_typespec that shares its span.
//       OWNSPAN=N means some OTHER class_typespec of a DIFFERENT name has the
//       same span — i.e. the span belongs to another typedef.
//   CLSSPAN|<tag>|<ts name>|<span>        DUMP-ONLY (spans are not judge-visible)
//
// The typespec SPAN and VpiFile are NOT in any scored payload:
// `typespec::Compare` reads VpiType / VpiName / Typedef_alias / Instance and
// never a span (RESUME.md §9).
//
// build: g++ -O2 -std=c++17 ct202cen.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct202cen
// usage: ct202cen <db.uhdm> <tag>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <algorithm>
#include <cstdio>
#include <map>
#include <set>
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
static std::string base(std::string_view p) {
    size_t i = p.find_last_of('/');
    return std::string(i == std::string_view::npos ? p : p.substr(i + 1));
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
// the last `::` segment of a name
static std::string tail(const std::string& n) {
    size_t i = n.rfind("::");
    return i == std::string::npos ? n : n.substr(i + 2);
}

int main(int argc, char** argv) {
    if (argc < 3) { fprintf(stderr, "usage: ct202cen <db.uhdm> <tag>\n"); return 2; }
    Serializer S;
    if (S.Restore(std::string(argv[1])).empty()) { printf("RESTORE_FAIL\n"); return 3; }
    const char* tag = argv[2];
    std::vector<std::string> rows;
    // ---- pass 1: every class_typespec, grouped by (file,span) for OWNSPAN
    std::vector<const class_typespec*> cls;
    std::map<std::string, std::set<std::string>> byspan;  // file:span -> name tails
    for (auto& kv : S.AllObjects()) {
        const BaseClass* X = kv.first;
        if (!X || X->UhdmType() != uhdmclass_typespec) continue;
        const class_typespec* c = (const class_typespec*)X;
        cls.push_back(c);
        byspan[base(c->VpiFile()) + ":" + span(c)].insert(
            tail(std::string(c->VpiName())));
    }
    for (const class_typespec* c : cls) {
        const std::string nm(c->VpiName());
        const std::string sp = base(c->VpiFile()) + ":" + span(c);
        const bool own = byspan[sp].size() <= 1;
        std::string cd = "-";
        if (const class_defn* d = c->Class_defn())
            cd = std::string(UhdmName(d->UhdmType())) + ":" +
                 std::string(d->VpiName());
        std::string al = "-";
        if (c->Typedef_alias()) {
            const typespec* a = c->Typedef_alias()->Actual_typespec();
            al = a ? std::string(UhdmName(a->UhdmType())) + ":" +
                         std::string(a->VpiName())
                   : std::string("<null>");
        }
        rows.push_back(std::string("CLS|") + tag + "|" + nm + "|" + cd +
                       "|ALIAS=" + al + "|OWNSPAN=" + (own ? "Y" : "N"));
        rows.push_back(std::string("CLSSPAN|") + tag + "|" + nm + "|" + sp);
    }
    // ---- pass 2: the declaration census (ct198cen's own rows)
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
