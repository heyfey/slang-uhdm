// r10uvm177 — THE OWNER-FINDER / JUDGE DECODER for the return-variable head.
// MEASUREMENT ONLY; the official `~/git-repos/UHDM/build/bin/uhdm-cmp` is the
// sole judge; this tool links the SAME generated `Compare` and only reports.
// LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
//
// The r10uvm174 R0 head is a `VpiType` mismatch (`BaseClass::Compare`'s FIRST
// test), so `m_failedLhs` and `m_failedRhs` are BOTH set.  This tool answers,
// symmetrically and with the generated kind-agnostic `GetByVpiType`:
//   step 1  which EDGE of which owner holds the head, on BOTH sides
//   step 2  the head object's FULL field vector on both sides
//   step 3  the golden typespec target's IDENTITY: every object in the golden
//           database whose ref_typespec resolves to it, and the same scan on
//           our side for our target — the "shared with which references"
//           question, asked of the raw databases
//   step 4  a DIRECT generated Compare of the two typespec targets, so the
//           pass knows BEFORE patching whether a bare re-kind clears the head
//           or merely uncovers the next field.
//
// build: g++ -O2 -std=c++17 ct177own.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct177own
// usage: ct177own <golden.uhdm> <ours.uhdm> <fnFullName>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <algorithm>
#include <cstdio>
#include <cstring>
#include <map>
#include <set>
#include <string>
#include <vector>

using namespace UHDM;

static std::string ident(const BaseClass* o) {
    if (!o) return "<null>";
    char b[1400];
    snprintf(b, sizeof b, "%s(%s)@%u:%u-%u:%u#%u",
             UhdmName(o->UhdmType()).data(), std::string(o->VpiName()).c_str(),
             o->VpiLineNo(), (unsigned)o->VpiColumnNo(), o->VpiEndLineNo(),
             (unsigned)o->VpiEndColumnNo(), o->UhdmId());
    return b;
}
static std::string parentPath(const BaseClass* o) {
    std::string s;
    int g = 0;
    for (const BaseClass* p = o->VpiParent(); p && g < 64;
         p = p->VpiParent(), ++g) {
        s += "<";
        s += UhdmName(p->UhdmType());
        s += ":";
        s += p->VpiName();
        s += ":";
        s += std::to_string(p->VpiLineNo());
    }
    return s;
}

// every object that carries a ref_typespec resolving to `target`
static void refsTo(Serializer& s, const BaseClass* target, const char* tag) {
    int n = 0;
    for (auto& kv : s.AllObjects()) {
        const BaseClass* o = kv.first;
        if (!o || o->UhdmType() != uhdmref_typespec) continue;
        const ref_typespec* rt = (const ref_typespec*)o;
        if (rt->Actual_typespec() != target) continue;
        ++n;
        printf("  %s ref_typespec#%u parent=%s\n", tag, rt->UhdmId(),
               ident(rt->VpiParent()).c_str());
    }
    printf("  %s TOTAL refs = %d\n", tag, n);
}

static void dumpTypespec(const typespec* t, const char* tag) {
    if (!t) { printf("  %s <null>\n", tag); return; }
    printf("  %s %s  parentchain=%s\n", tag, ident(t).c_str(),
           parentPath(t).c_str());
    printf("    Instance = %s\n",
           t->Instance() ? ident(t->Instance()).c_str() : "<null>");
    const ref_typespec* ta = t->Typedef_alias();
    printf("    Typedef_alias = %s -> %s\n",
           ta ? ident(ta).c_str() : "<null>",
           (ta && ta->Actual_typespec()) ? ident(ta->Actual_typespec()).c_str()
                                         : "<null>");
    if (t->UhdmType() == uhdmenum_typespec) {
        const enum_typespec* e = (const enum_typespec*)t;
        const ref_typespec* bt = e->Base_typespec();
        printf("    Base_typespec = %s -> %s\n",
               bt ? ident(bt).c_str() : "<null>",
               (bt && bt->Actual_typespec())
                   ? ident(bt->Actual_typespec()).c_str()
                   : "<null>");
        auto* ec = e->Enum_consts();
        printf("    Enum_consts = %zu\n", ec ? ec->size() : 0u);
        if (ec)
            for (auto* c : *ec)
                printf("      %s val=%s decomp=%s\n", ident(c).c_str(),
                       std::string(c->VpiValue()).c_str(),
                       std::string(c->VpiDecompile()).c_str());
    }
}

static const function* findFn(Serializer& s, const std::string& full,
                              unsigned line) {
    for (auto& kv : s.AllObjects()) {
        const BaseClass* o = kv.first;
        if (!o || o->UhdmType() != uhdmfunction) continue;
        if (o->VpiLineNo() != line) continue;
        const function* f = (const function*)o;
        if (f->VpiFullName() == full || f->VpiName() == full) return f;
    }
    return nullptr;
}

int main(int argc, char** argv) {
    if (argc < 4) {
        fprintf(stderr, "usage: ct177own <golden.uhdm> <ours.uhdm> <line>\n");
        return 2;
    }
    unsigned line = (unsigned)atoi(argv[3]);
    Serializer sg, so;
    if (sg.Restore(std::string(argv[1])).empty()) { printf("RESTORE_FAIL_G\n"); return 3; }
    if (so.Restore(std::string(argv[2])).empty()) { printf("RESTORE_FAIL_O\n"); return 3; }

    for (int side = 0; side < 2; ++side) {
        Serializer& s = side ? so : sg;
        const char* tag = side ? "OURS  " : "GOLDEN";
        printf("=== %s: every `function` at line %u ===\n", tag, line);
        for (auto& kv : s.AllObjects()) {
            const BaseClass* o = kv.first;
            if (!o || o->UhdmType() != uhdmfunction) continue;
            if (o->VpiLineNo() != line) continue;
            const function* f = (const function*)o;
            printf("%s fn %s\n   chain=%s\n", tag, ident(f).c_str(),
                   parentPath(f).c_str());
            const variables* rv = f->Return();
            if (!rv) { printf("   Return = <null>\n"); continue; }
            printf("   Return = %s  fullname=%s signed=%d\n", ident(rv).c_str(),
                   std::string(rv->VpiFullName()).c_str(),
                   (int)rv->VpiSigned());
            const ref_typespec* rt = rv->Typespec();
            printf("   Return.Typespec = %s\n", rt ? ident(rt).c_str() : "<null>");
            if (rt) dumpTypespec(rt->Actual_typespec(), "   actual");
            if (rt && rt->Actual_typespec()) {
                printf("   --- who else points at that typespec ---\n");
                refsTo(s, rt->Actual_typespec(), tag);
            }
        }
    }

    // step 4: direct generated Compare of the two Return objects and of the
    // two typespec targets.
    const function* fg = nullptr;
    const function* fo = nullptr;
    for (auto& kv : sg.AllObjects())
        if (kv.first && kv.first->UhdmType() == uhdmfunction &&
            kv.first->VpiLineNo() == line && ((const function*)kv.first)->Return())
            fg = (const function*)kv.first;
    for (auto& kv : so.AllObjects())
        if (kv.first && kv.first->UhdmType() == uhdmfunction &&
            kv.first->VpiLineNo() == line && ((const function*)kv.first)->Return())
            fo = (const function*)kv.first;
    if (fg && fo && fg->Return()->Typespec() && fo->Return()->Typespec()) {
        const typespec* tg = fg->Return()->Typespec()->Actual_typespec();
        const typespec* to = fo->Return()->Typespec()->Actual_typespec();
        CompareContext ctx;
        int r = tg ? tg->Compare(to, &ctx) : -99;
        printf("=== TYPESPEC-vs-TYPESPEC generated Compare: r=%d\n", r);
        printf("    failedLhs=%s\n    failedRhs=%s\n",
               ident(ctx.m_failedLhs).c_str(), ident(ctx.m_failedRhs).c_str());
        CompareContext ctx2;
        int r2 = fg->Return()->Compare(fo->Return(), &ctx2);
        printf("=== RETURN-vs-RETURN generated Compare: r=%d\n", r2);
        printf("    failedLhs=%s\n    failedRhs=%s\n",
               ident(ctx2.m_failedLhs).c_str(), ident(ctx2.m_failedRhs).c_str());
    }
    return 0;
}
