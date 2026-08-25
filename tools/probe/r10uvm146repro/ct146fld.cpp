// r10uvm146 — FIELD TABLE for the design-level imported parameter clones vs the
// two package views' own parameter objects.  MEASUREMENT ONLY.
// Prints exactly the fields `parameter::Compare` reads (RESUME §9: read the
// generated Compare before naming a field).
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <string>
using namespace UHDM;
static void row(const char* tag, const any* p) {
    if (!p) return;
    if (p->UhdmType() != uhdmparameter) {
        printf("%s|%s|KIND=%s\n", tag, std::string(p->VpiName()).c_str(),
               std::string(UhdmName(p->UhdmType())).c_str());
        return;
    }
    const parameter* q = (const parameter*)p;
    std::string tsk = "-";
    if (q->Typespec() && q->Typespec()->Actual_typespec())
        tsk = std::string(UhdmName(q->Typespec()->Actual_typespec()->UhdmType()));
    printf("%s|%s|dec='%s'|size=%d|ct=%d|sgn=%d|lp=%d|imp='%s'|ts=%s|expr=%d|rng=%zu\n",
           tag, std::string(q->VpiName()).c_str(),
           std::string(q->VpiDecompile()).c_str(), q->VpiSize(), q->VpiConstType(),
           (int)q->VpiSigned(), (int)q->VpiLocalParam(),
           std::string(q->VpiImported()).c_str(), tsk.c_str(), q->Expr() ? 1 : 0,
           q->Ranges() ? q->Ranges()->size() : 0);
}
int main(int argc, char** argv) {
    if (argc < 2) return 2;
    Serializer s;
    const std::vector<vpiHandle> h = s.Restore(std::string(argv[1]));
    if (h.empty()) return 3;
    const design* d = (const design*)((const uhdm_handle*)h[0])->object;
    if (d->Parameters()) for (auto* p : *d->Parameters()) row("DESIGN", p);
    if (d->AllPackages()) for (auto* p : *d->AllPackages())
        if (p->Parameters()) for (auto* q : *p->Parameters()) row("PKGDEF", q);
    if (d->TopPackages()) for (auto* p : *d->TopPackages())
        if (p->Parameters()) for (auto* q : *p->Parameters()) row("PKGTOP", q);
    if (d->Param_assigns()) for (auto* pa : *d->Param_assigns())
        printf("PAD|%s|%s|%u:%u\n", pa->Lhs()?std::string(pa->Lhs()->VpiName()).c_str():"-",
               pa->Rhs()?std::string(UhdmName(pa->Rhs()->UhdmType())).c_str():"-",
               pa->VpiLineNo(), (unsigned)pa->VpiColumnNo());
    if (d->AllPackages()) for (auto* p : *d->AllPackages())
        if (p->Param_assigns()) for (auto* pa : *p->Param_assigns())
            printf("PAD_DEF|%s|%s|%u:%u\n", pa->Lhs()?std::string(pa->Lhs()->VpiName()).c_str():"-",
                   pa->Rhs()?std::string(UhdmName(pa->Rhs()->UhdmType())).c_str():"-",
                   pa->VpiLineNo(), (unsigned)pa->VpiColumnNo());
    if (d->TopPackages()) for (auto* p : *d->TopPackages())
        if (p->Param_assigns()) for (auto* pa : *p->Param_assigns())
            printf("PAD_TOP|%s|%s|%u:%u\n", pa->Lhs()?std::string(pa->Lhs()->VpiName()).c_str():"-",
                   pa->Rhs()?std::string(UhdmName(pa->Rhs()->UhdmType())).c_str():"-",
                   pa->VpiLineNo(), (unsigned)pa->VpiColumnNo());
    return 0;
}
