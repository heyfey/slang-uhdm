// r10uvm227 — COPIED VERBATIM from r10uvm226repro/ct226inner.cpp (only this
// header line and the banner string differ), so the reading is the SAME
// instrument the previous pass used and the head can be compared across the
// two passes without an instrument change.
// r10uvm226 — WHICH OBJECT INSIDE THE HEAD'S `Process()` VECTOR DISAGREES.
// MEASUREMENT-ONLY; the official `uhdm-cmp` remains the sole acceptance judge.
//
// `ct227field` names the FIELD of the head object that fails.  When that field
// is a VECTOR whose two sides are the SAME SIZE, the failure is inside an
// ELEMENT, and `uhdm-cmp` still prints the OWNER — the vector overload's
// `LHS: <owner>` / `RHS: <owner>` signature (RESUME §9) — so the cmp log cannot
// say which object it was.  This probe runs the SHIPPED `BaseClass::Compare` on
// each element pair in a FRESH `CompareContext` and prints the context's own
// `m_failedLhs` / `m_failedRhs`, which is the exact object pair the judge
// stopped on.  Nothing in UHDM is patched.
//
//   build: g++ -O2 -std=c++17 ct227inner.cpp -I ~/.local/include \
//              -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj \
//              -o ct227inner
//   usage: ./ct227inner <golden.uhdm> <ours.uhdm> <VpiFullName>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <cstdio>
#include <filesystem>
#include <string>

using namespace UHDM;

static const interface_inst* findIface(Serializer& s, const std::string& name) {
    for (auto& [obj, id] : s.AllObjects()) {
        (void)id;
        if (!obj || obj->UhdmType() != uhdminterface_inst)
            continue;
        auto* ii = (const interface_inst*)obj;
        if (ii->VpiFullName() == name)
            return ii;
    }
    return nullptr;
}

static void describe(const char* tag, const BaseClass* b) {
    if (!b) {
        printf("  %s <null>\n", tag);
        return;
    }
    const any* a = any_cast<const any*>(b);
    printf("  %s type=%d name=%s file=%s line=%u:%u..%u:%u\n", tag,
           (int)b->UhdmType(), a ? std::string(a->VpiName()).c_str() : "-",
           std::string(b->VpiFile()).c_str(), b->VpiLineNo(), b->VpiColumnNo(),
           b->VpiEndLineNo(), b->VpiEndColumnNo());
}

int main(int argc, char** argv) {
    if (argc < 4) {
        fprintf(stderr, "usage: ct227inner <golden> <ours> <VpiFullName>\n");
        return 2;
    }
    Serializer sg, so;
    auto hg = sg.Restore(std::filesystem::path(argv[1]));
    auto ho = so.Restore(std::filesystem::path(argv[2]));
    if (hg.empty() || ho.empty()) {
        fprintf(stderr, "RESTORE FAILED\n");
        return 3;
    }
    const interface_inst* g = findIface(sg, argv[3]);
    const interface_inst* o = findIface(so, argv[3]);
    printf("# ct227inner MEASUREMENT-ONLY — uhdm-cmp remains the sole judge\n");
    printf("# GOLDEN %s\n# OURS   %s\n# OBJECT %s\n", argv[1], argv[2], argv[3]);
    if (!g || !o) {
        printf("NOT FOUND golden=%d ours=%d\n", g != nullptr, o != nullptr);
        return 4;
    }
    auto* gv = g->Process();
    auto* ov = o->Process();
    printf("Process golden=%zu ours=%zu\n", gv ? gv->size() : 0,
           ov ? ov->size() : 0);
    if (!gv || !ov)
        return 0;
    size_t n = gv->size() < ov->size() ? gv->size() : ov->size();
    for (size_t i = 0; i < n; i++) {
        CompareContext c;
        int r = gv->at(i)->Compare(ov->at(i), &c);
        printf("ELEMENT[%zu] golden_type=%d ours_type=%d r=%d %s\n", i,
               (int)gv->at(i)->UhdmType(), (int)ov->at(i)->UhdmType(), r,
               r ? "<-- DISAGREES" : "agrees");
        if (r) {
            describe("failedLhs(golden)", c.m_failedLhs);
            describe("failedRhs(ours)  ", c.m_failedRhs);
        }
    }
    return 0;
}
