// r10uvm149 — A-PRIORI MOVER PREDICTOR, run over the GOLDEN databases BEFORE
// the patched sweep.  MEASUREMENT ONLY; the sole acceptance judge is the
// official ~/git-repos/UHDM/build/bin/uhdm-cmp.
//
// LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
//
// § structMemberWrittenQueueArrayTs149 fires exactly where a struct/union
// member is WRITTEN with a queue dimension.  Golden's signature for that
// member is unmistakable and is what this tool counts: a typespec_member whose
// Actual_typespec is a NAMELESS, INSTANCE-LESS `array_typespec` carrying ONE
// range with a `vpiUnboundedConst` bound.  (A member written with a TYPEDEF of
// a queue binds the typedef's own array_typespec, which is NAMED and carries
// vpiInstance — those are excluded, because the law does not fire there.)
//
// Rows:  CAND <label> <owner>|<member> <side>=<decompile>
// Tail:  TOTAL <label> cands=<n>
//
//   build: g++ -O2 -std=c++17 pred149.cpp -I ~/.local/include \
//              -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o pred149
//   usage: pred149 <golden.uhdm> <label>
#include <uhdm/uhdm.h>
#include <uhdm/Serializer.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <string>
using namespace UHDM;

static bool unbounded(const any* e) {
    return e && e->UhdmType() == uhdmconstant &&
           ((const constant*)e)->VpiConstType() == vpiUnboundedConst;
}

int main(int argc, char** argv) {
    if (argc < 3) { fprintf(stderr, "usage: pred149 <db> <label>\n"); return 2; }
    const std::string label = argv[2];
    Serializer s;
    auto restored = s.Restore(std::string(argv[1]));
    if (restored.empty()) { printf("EMPTY\t%s\n", label.c_str()); return 3; }
    int cands = 0;
    for (auto& kv : s.AllObjects()) {
        const any* a = (const any*)kv.first;
        if (!a || a->UhdmType() != uhdmtypespec_member) continue;
        const typespec_member* m = (const typespec_member*)a;
        if (!m->Typespec()) continue;
        const typespec* ts = m->Typespec()->Actual_typespec();
        if (!ts || ts->UhdmType() != uhdmarray_typespec) continue;
        const array_typespec* at = (const array_typespec*)ts;
        if (!at->VpiName().empty() || at->Instance()) continue;
        if (!at->Ranges() || at->Ranges()->size() != 1) continue;
        const range* r = (*at->Ranges())[0];
        bool lu = unbounded(r->Left_expr()), ru = unbounded(r->Right_expr());
        if (!lu && !ru) continue;
        const any* p = m->VpiParent();
        cands++;
        printf("CAND\t%s\t%s|%s\t%s\n", label.c_str(),
               p ? std::string(p->VpiName()).c_str() : "<noparent>",
               std::string(m->VpiName()).c_str(),
               lu ? "left=$" : "right=$");
    }
    printf("TOTAL\t%s\tcands=%d\n", label.c_str(), cands);
    return 0;
}
