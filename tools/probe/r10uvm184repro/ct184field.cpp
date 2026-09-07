// r10uvm184 — THE FAILING FIELD of one object pair.  MEASUREMENT ONLY.
// LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
//
// Given two object ids (golden, ours) the tool runs the generated `Compare` on
// exactly that pair and then walks EVERY `GetByVpiType` edge of both, printing
// singular presence and vector size on each side.  That is what tells a
// "SINGULAR value missing" head (`RHS: <null>` naming the VALUE) apart from a
// "VECTOR is NULL on ours" head, where BaseClass.h's vector overload sets the
// OWNER as LHS and leaves RHS unset (RESUME.md §9).
//
// build: g++ -O2 -std=c++17 ct184field.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct184field
// usage: ct184field <golden.uhdm> <ours.uhdm> <golden-id> <ours-id>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <cstdio>
#include <cstdlib>
#include <string>

using namespace UHDM;

static std::string ident(const BaseClass* o) {
    if (!o) return "<null>";
    char b[900];
    snprintf(b, sizeof b, "%s(%s)@%u:%u-%u:%u#%u",
             std::string(UhdmName(o->UhdmType())).c_str(),
             std::string(o->VpiName()).c_str(), o->VpiLineNo(),
             (unsigned)o->VpiColumnNo(), o->VpiEndLineNo(),
             (unsigned)o->VpiEndColumnNo(), o->UhdmId());
    return b;
}
static const BaseClass* byId(Serializer& s, uint32_t id) {
    for (auto& kv : s.AllObjects())
        if (kv.first && kv.first->UhdmId() == id) return kv.first;
    return nullptr;
}

int main(int argc, char** argv) {
    if (argc < 5) {
        fprintf(stderr, "usage: ct184field <golden> <ours> <gid> <oid>\n");
        return 2;
    }
    Serializer sg, so;
    if (sg.Restore(std::string(argv[1])).empty()) { printf("RESTORE_FAIL golden\n"); return 3; }
    if (so.Restore(std::string(argv[2])).empty()) { printf("RESTORE_FAIL ours\n"); return 3; }
    const BaseClass* L = byId(sg, (uint32_t)atoi(argv[3]));
    const BaseClass* R = byId(so, (uint32_t)atoi(argv[4]));
    printf("GOLDEN %s\nOURS   %s\n", ident(L).c_str(), ident(R).c_str());
    if (!L || !R) return 3;
    CompareContext c;
    int r = L->Compare(R, &c);
    printf("pair Compare r=%d\n  failedLhs=%s\n  failedRhs=%s\n", r,
           ident(c.m_failedLhs).c_str(), ident(c.m_failedRhs).c_str());
    printf("EDGES (vpiType : golden | ours)\n");
    for (int t = 1; t <= 2100; ++t) {
        auto tl = L->GetByVpiType(t);
        auto tr = R->GetByVpiType(t);
        const BaseClass* l1 = std::get<0>(tl);
        const BaseClass* r1 = std::get<0>(tr);
        const std::vector<const BaseClass*>* lv = std::get<2>(tl);
        const std::vector<const BaseClass*>* rv = std::get<2>(tr);
        if (!l1 && !r1 && !lv && !rv) continue;
        char lb[600], rb[600];
        if (lv) snprintf(lb, sizeof lb, "vector n=%zu", lv->size());
        else snprintf(lb, sizeof lb, "%s", ident(l1).c_str());
        if (rv) snprintf(rb, sizeof rb, "vector n=%zu", rv->size());
        else snprintf(rb, sizeof rb, "%s", ident(r1).c_str());
        const bool diff = (lv != nullptr) != (rv != nullptr) ||
                          (lv && rv && lv->size() != rv->size()) ||
                          (!lv && !rv && ((l1 != nullptr) != (r1 != nullptr)));
        printf("  %s%5d : %-52s | %s\n", diff ? "*" : " ", t, lb, rb);
        if (lv)
            for (size_t i = 0; i < lv->size(); ++i)
                printf("            g[%zu] %s\n", i, ident(lv->at(i)).c_str());
        if (rv)
            for (size_t i = 0; i < rv->size(); ++i)
                printf("            o[%zu] %s\n", i, ident(rv->at(i)).c_str());
    }
    return 0;
}
