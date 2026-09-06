// r10uvm170 — THE CAST-TYPESPEC / UNSUPPORTED-TYPESPEC CENSUS.
//
// MEASUREMENT ONLY.  The official `uhdm-cmp` is the sole acceptance judge.
// LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
//
// Two listings, both keyed on things `typespec::Compare` / `operation::Compare`
// actually read (kind + name) plus the SPAN, which is the only stable join key
// across two independently built databases:
//
//   --casts   every `operation` whose `VpiOpType == vpiCastOp`: the operation's
//             span, the KIND and NAME of `Typespec()->Actual_typespec()`, and
//             the enclosing scope chain (nearest subroutine, its owner class or
//             package, and whether the subroutine is class-scoped).
//   --unsup   every `unsupported_typespec` in the database: name, span,
//             `Instance()` (the § 83 / § 88 stamp), and the referrer FIELD +
//             the referrer's own owner chain, so a placeholder is attributed to
//             a construct and not to "a typespec somewhere".
//   --tsrefs  every `ref_typespec` whose parent is an operation/io_decl/var,
//             with the Actual kind — the REVERSE column (golden RESOLVED).
//
// Output is one TAB-separated record per line, prefixed by the listing name, so
// two databases can be joined by `join170.py` without re-parsing a dump.
//
// build: g++ -O2 -std=c++17 ct170cen.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct170cen
// usage: ct170cen <db.uhdm> --casts|--unsup|--tsrefs
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <cstdio>
#include <cstring>
#include <string>
#include <vector>

using namespace UHDM;

static std::string base(std::string_view p) {
    size_t i = p.find_last_of('/');
    return std::string(i == std::string_view::npos ? p : p.substr(i + 1));
}
static std::string span(const BaseClass* o) {
    if (!o) return "<null>";
    char b[256];
    snprintf(b, sizeof b, "%s:%u:%u-%u:%u", base(o->VpiFile()).c_str(),
             o->VpiLineNo(), (unsigned)o->VpiColumnNo(), o->VpiEndLineNo(),
             (unsigned)o->VpiEndColumnNo());
    return b;
}
static std::string lineonly(const BaseClass* o) {
    if (!o) return "<null>";
    char b[64];
    snprintf(b, sizeof b, "%u:%u", o->VpiLineNo(), (unsigned)o->VpiColumnNo());
    return b;
}
static std::string kindOf(const BaseClass* o) {
    return o ? std::string(UhdmName(o->UhdmType())) : std::string("<null>");
}
static std::string nameOf(const BaseClass* o) {
    return o ? std::string(o->VpiName()) : std::string("<null>");
}
// nearest enclosing subroutine / class / package, and the SITE word
static void scopeOf(const BaseClass* o, std::string& sub, std::string& subkind,
                    std::string& owner, std::string& ownerkind) {
    sub = subkind = owner = ownerkind = "-";
    // `owner` carries the owning scope's UhdmId too, so a DEF-view copy and an
    // ELAB-view copy of the same package can be told apart (they share a name).
    for (const BaseClass* p = o ? o->VpiParent() : nullptr; p;
         p = p->VpiParent()) {
        UHDM_OBJECT_TYPE t = p->UhdmType();
        if (sub == "-" && (t == uhdmfunction || t == uhdmtask)) {
            sub = nameOf(p);
            subkind = kindOf(p);
            continue;
        }
        if (t == uhdmclass_defn || t == uhdmpackage || t == uhdmmodule_inst) {
            owner = nameOf(p) + "#" + std::to_string(p->UhdmId());
            ownerkind = kindOf(p);
            break;
        }
    }
}

int main(int argc, char** argv) {
    if (argc < 3) { fprintf(stderr, "usage: ct170cen <db> --casts|--unsup|--tsrefs\n"); return 2; }
    const bool casts = !strcmp(argv[2], "--casts");
    const bool unsup = !strcmp(argv[2], "--unsup");
    const bool tsrefs = !strcmp(argv[2], "--tsrefs");
    Serializer s;
    if (s.Restore(std::string(argv[1])).empty()) { printf("RESTORE_FAIL\n"); return 3; }

    size_t n = 0;
    for (auto& kv : s.AllObjects()) {
        const BaseClass* o = (const BaseClass*)kv.first;
        if (!o) continue;
        const UHDM_OBJECT_TYPE t = o->UhdmType();
        std::string sub, subk, own, ownk;

        if (casts && t == uhdmoperation) {
            const operation* op = (const operation*)o;
            if (op->VpiOpType() != vpiCastOp) continue;
            const ref_typespec* rt = op->Typespec();
            const typespec* act = rt ? rt->Actual_typespec() : nullptr;
            scopeOf(o, sub, subk, own, ownk);
            printf("CAST\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n", span(o).c_str(),
                   kindOf(act).c_str(), nameOf(act).c_str(),
                   act ? lineonly(act).c_str() : "-", subk.c_str(), sub.c_str(),
                   (ownk + ":" + own).c_str());
            ++n;
        }
        if (unsup && t == uhdmunsupported_typespec) {
            const unsupported_typespec* u = (const unsupported_typespec*)o;
            const BaseClass* inst = u->Instance();
            scopeOf(o, sub, subk, own, ownk);
            printf("UNSUP\t%s\t%s\tinst=%s:%s#%u\tparent=%s\tsub=%s:%s\towner=%s\n",
                   span(o).c_str(), nameOf(o).c_str(), kindOf(inst).c_str(),
                   nameOf(inst).c_str(), inst ? inst->UhdmId() : 0u,
                   kindOf(o->VpiParent()).c_str(), subk.c_str(), sub.c_str(),
                   (ownk + ":" + own).c_str());
            ++n;
        }
        if (tsrefs && t == uhdmref_typespec) {
            const ref_typespec* rt = (const ref_typespec*)o;
            const typespec* act = rt->Actual_typespec();
            const BaseClass* par = rt->VpiParent();
            scopeOf(o, sub, subk, own, ownk);
            printf("TSREF\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n",
                   par ? span(par).c_str() : "<null>", kindOf(par).c_str(),
                   kindOf(act).c_str(), nameOf(act).c_str(), subk.c_str(),
                   sub.c_str(), (ownk + ":" + own).c_str());
            ++n;
        }
    }
    fprintf(stderr, "ROWS=%zu\n", n);
    return 0;
}
