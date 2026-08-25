// r10uvm146 — NEXT-HEAD PREDICTOR for the design-level imported-parameter head.
// MEASUREMENT ONLY.  ~/git-repos/UHDM/build/bin/uhdm-cmp is the sole judge;
// this tool links the SAME generated Compare and only reports.
//
// LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
//
// Every generated `<kind>::Compare` opens with an LHS-keyed
// `m_visited.insert(this)` and returns 0 on a hit, so seeding a GOLDEN object
// makes exactly the comparisons that reach it succeed.  Masking the whole
// design-level imported-parameter SET therefore answers "what does the judge
// read next once those objects agree" WITHOUT touching production.
//
// It also LISTS the design-level parameter/param_assign/typespec listings on
// both sides (the census this pass's law is scored on).
//
// build: g++ -O2 -std=c++17 ct146own.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct146own
// usage: ct146own <golden.uhdm> <ours.uhdm> [--mask=imported|none] [--list]
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
static std::string ident(const BaseClass* o) {
    if (!o) return "<null>";
    char b[900];
    const std::string kind(UhdmName(o->UhdmType()));
    const std::string nm(o->VpiName());
    snprintf(b, sizeof b, "%s(%s)@%s:%u:%u-%u:%u#%u", kind.c_str(), nm.c_str(),
             base(o->VpiFile()).c_str(), o->VpiLineNo(), (unsigned)o->VpiColumnNo(),
             o->VpiEndLineNo(), (unsigned)o->VpiEndColumnNo(), o->UhdmId());
    return b;
}
static void chain(const char* tag, const BaseClass* o, int n = 10) {
    printf("%s", tag);
    for (int i = 0; i < n && o; i++) {
        printf("%s%s\n", i ? "      < " : "", ident(o).c_str());
        o = o->VpiParent();
    }
    if (!o) printf("      < <root>\n");
}
struct Head { const BaseClass* lhs = nullptr; const BaseClass* rhs = nullptr; int r = 0; };
static Head runCompare(const design* dg, const design* dou,
                       const std::vector<const BaseClass*>& mask) {
    CompareContext c;
    for (const BaseClass* m : mask) c.m_visited.insert(m);
    Head h;
    h.r = dg->Compare(dou, &c);
    h.lhs = c.m_failedLhs;
    h.rhs = c.m_failedRhs;
    return h;
}
static void listDesign(const char* tag, const design* d) {
    size_t np = d->Parameters() ? d->Parameters()->size() : 0;
    size_t na = d->Param_assigns() ? d->Param_assigns()->size() : 0;
    size_t nt = d->Typespecs() ? d->Typespecs()->size() : 0;
    size_t ntf = d->Task_funcs() ? d->Task_funcs()->size() : 0;
    printf("%s design(%s) Parameters=%zu Param_assigns=%zu Typespecs=%zu Task_funcs=%zu\n",
           tag, std::string(d->VpiName()).c_str(), np, na, nt, ntf);
    if (d->Parameters())
        for (auto* p : *d->Parameters())
            printf("%s  PARAM %s kind=%s imported='%s' localparam=%d size=%d decompile='%s' ts=%d\n",
                   tag, std::string(p->VpiName()).c_str(),
                   std::string(UhdmName(p->UhdmType())).c_str(),
                   p->UhdmType() == uhdmparameter
                       ? std::string(((const parameter*)p)->VpiImported()).c_str()
                       : "",
                   p->UhdmType() == uhdmparameter ? (int)((const parameter*)p)->VpiLocalParam() : -1,
                   p->UhdmType() == uhdmparameter ? ((const parameter*)p)->VpiSize() : -1,
                   p->UhdmType() == uhdmparameter
                       ? std::string(((const parameter*)p)->VpiDecompile()).c_str()
                       : "",
                   (p->UhdmType() == uhdmparameter && ((const parameter*)p)->Typespec()) ? 1 : 0);
    if (d->Param_assigns())
        for (auto* pa : *d->Param_assigns())
            printf("%s  PASSIGN lhs=%s rhs=%s @%u:%u\n", tag,
                   pa->Lhs() ? std::string(pa->Lhs()->VpiName()).c_str() : "<null>",
                   pa->Rhs() ? std::string(UhdmName(pa->Rhs()->UhdmType())).c_str() : "<null>",
                   pa->VpiLineNo(), (unsigned)pa->VpiColumnNo());
}
int main(int argc, char** argv) {
    if (argc < 3) {
        fprintf(stderr, "usage: ct146own golden ours [--mask=imported] [--list]\n");
        return 2;
    }
    bool maskImported = false, doList = false;
    for (int a = 3; a < argc; a++) {
        if (!strcmp(argv[a], "--mask=imported")) maskImported = true;
        else if (!strcmp(argv[a], "--list")) doList = true;
    }
    Serializer sg, so;
    const std::vector<vpiHandle> hg = sg.Restore(std::string(argv[1]));
    const std::vector<vpiHandle> ho = so.Restore(std::string(argv[2]));
    if (hg.empty() || ho.empty()) { fprintf(stderr, "restore failed\n"); return 3; }
    const design* dg = (const design*)((const uhdm_handle*)hg[0])->object;
    const design* dou = (const design*)((const uhdm_handle*)ho[0])->object;

    if (doList) { listDesign("GOLD", dg); listDesign("OURS", dou); }

    Head h0 = runCompare(dg, dou, {});
    printf("HEAD r=%d\n", h0.r);
    chain("LHS: ", h0.lhs);
    chain("RHS: ", h0.rhs);

    if (maskImported) {
        std::vector<const BaseClass*> mask;
        for (const auto& [obj, id] : sg.AllObjects()) {
            if (!obj || obj->UhdmType() != uhdmparameter) continue;
            if (((const parameter*)obj)->VpiImported().empty()) continue;
            const BaseClass* p = obj->VpiParent();
            if (!p || p->UhdmType() != uhdmdesign) continue;
            mask.push_back(obj);
        }
        Head h = runCompare(dg, dou, mask);
        printf("MASK design-imported-parameters n=%zu -> %s r=%d\n", mask.size(),
               (h.lhs == h0.lhs && h.rhs == h0.rhs && h.r == h0.r) ? "HEAD-UNCHANGED"
                                                                   : "HEAD-MOVED",
               h.r);
        chain("  newLHS: ", h.lhs);
        chain("  newRHS: ", h.rhs);
    }
    return 0;
}
