// r10uvm212 — THE FIELD-TABLE PROBE.  MEASUREMENT ONLY; the official
// `~/git-repos/UHDM/build/bin/uhdm-cmp` is the sole judge.  This tool links the
// SAME generated `Compare` and only reports.  LHS is ALWAYS golden (Surelog),
// RHS is ALWAYS ours.
//
// WHY IT EXISTS.  BaseClass.h's two SafeCompare overloads BOTH can print
// `LHS: <null>` with a full RHS, and they mean OPPOSITE things:
//   * the SINGULAR overload (`BaseClass.h:194-196`) sets `m_failedRhs` to the
//     FIELD VALUE — the owner is not printed;
//   * the VECTOR overload (`BaseClass.h:220-222`) sets `m_failedRhs` to the
//     OWNER OBJECT (`rhs_obj`) when golden's vector POINTER is null and ours is
//     non-empty — the field is not printed.
// So a head dump alone cannot tell you which field moved.  This probe takes the
// head object, matches its counterpart on the other side by FACE (kind + name +
// span) and ancestor-face path, and prints EVERY `GetByVpiType` edge of both,
// singular and vector, with `NULLVEC` distinguished from `size 0`.  The single
// row where golden reads NULLVEC and ours reads a non-empty vector IS the head
// under the vector overload; a row where golden reads `-` (null singular) and
// ours a value is the head under the singular overload.
//
// build: g++ -O2 -std=c++17 ct212fields.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct212fields
// usage: ct212fields <golden.uhdm> <ours.uhdm>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <cstdio>
#include <string>
#include <vector>

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
static const design* topDesign(Serializer& s) {
    for (auto& kv : s.AllObjects())
        if (kv.first && kv.first->UhdmType() == uhdmdesign)
            return (const design*)kv.first;
    return nullptr;
}
static std::string parentPath(const BaseClass* o) {
    std::string s;
    for (const BaseClass* p = o->VpiParent(); p; p = p->VpiParent()) {
        s += "<";
        s += UhdmName(p->UhdmType());
        s += ":";
        s += p->VpiName();
        s += ":";
        s += std::to_string(p->VpiLineNo());
    }
    return s;
}
static bool sameFace(const BaseClass* a, const BaseClass* b) {
    return a->UhdmType() == b->UhdmType() &&
           std::string(a->VpiName()) == std::string(b->VpiName()) &&
           a->VpiLineNo() == b->VpiLineNo() &&
           a->VpiColumnNo() == b->VpiColumnNo() &&
           a->VpiEndLineNo() == b->VpiEndLineNo() &&
           a->VpiEndColumnNo() == b->VpiEndColumnNo();
}
static std::string cell(const BaseClass* X, int t, bool& present) {
    present = false;
    if (!X) return "(no counterpart)";
    auto tup = X->GetByVpiType(t);
    const BaseClass* one = std::get<0>(tup);
    const std::vector<const BaseClass*>* vec = std::get<2>(tup);
    if (one) { present = true; return "SING " + ident(one); }
    if (vec) {
        present = !vec->empty();
        char b[200];
        snprintf(b, sizeof b, "VEC size %zu", vec->size());
        std::string s = b;
        if (!vec->empty()) s += " [0]=" + ident(vec->at(0));
        return s;
    }
    return "-";  // null singular AND null vector are indistinguishable here
}
static void table(const BaseClass* G, const BaseClass* O, const char* tag) {
    printf("---- FIELD TABLE (%s)\n", tag);
    printf("     golden = %s\n", ident(G).c_str());
    printf("     ours   = %s\n", ident(O).c_str());
    for (int t = 1; t <= 2100; ++t) {
        bool pg = false, po = false;
        std::string cg = G ? cell(G, t, pg) : std::string("(none)");
        std::string co = O ? cell(O, t, po) : std::string("(none)");
        if (cg == "-" && co == "-") continue;
        if (!pg && !po) continue;
        const char* mark = (cg == co) ? "   " : ">>>";
        printf("  %s vpiType=%-5d golden: %-64s ours: %s\n", mark, t, cg.c_str(),
               co.c_str());
    }
}

int main(int argc, char** argv) {
    if (argc < 3) { fprintf(stderr, "usage: ct212fields <golden> <ours>\n"); return 2; }
    Serializer sg, so;
    std::vector<vpiHandle> hg = sg.Restore(std::string(argv[1]));
    std::vector<vpiHandle> ho = so.Restore(std::string(argv[2]));
    if (hg.empty()) { printf("RESTORE_FAIL golden\n"); return 3; }
    if (ho.empty()) { printf("RESTORE_FAIL ours\n"); return 3; }
    printf("HANDLES golden=%zu ours=%zu\n", hg.size(), ho.size());
    { size_t ng=0, no2=0;
      for (auto& kv : sg.AllObjects()) if (kv.first && kv.first->UhdmType()==uhdmdesign) ++ng;
      for (auto& kv : so.AllObjects()) if (kv.first && kv.first->UhdmType()==uhdmdesign) ++no2;
      printf("DESIGN OBJECTS golden=%zu ours=%zu\n", ng, no2); }
    // uhdm-cmp uses the RESTORE HANDLE's design, not an AllObjects scan: a
    // second design object in the arena would make the two disagree.
    const design* dg = (const design*)((const uhdm_handle*)hg[0])->object;
    const design* dou = (const design*)((const uhdm_handle*)ho[0])->object;
    printf("HANDLE DESIGN golden=%s ours=%s\n", ident(dg).c_str(), ident(dou).c_str());
    printf("SCAN   DESIGN golden=%s ours=%s\n", ident(topDesign(sg)).c_str(), ident(topDesign(so)).c_str());
    if (!dg || !dou) { printf("NO_DESIGN\n"); return 3; }
    CompareContext c;
    int r = dg->Compare(dou, &c);
    printf("design::Compare r=%d\n", r);
    printf("HEAD LHS(golden) = %s\n", ident(c.m_failedLhs).c_str());
    printf("HEAD RHS(ours)   = %s\n", ident(c.m_failedRhs).c_str());

    // The head object lives on ONE side; find its counterpart on the other by
    // face + ancestor-face path.  Ambiguity is REPORTED, never silently
    // resolved: an ambiguous match would make the table meaningless.
    const BaseClass* H = c.m_failedRhs ? c.m_failedRhs : c.m_failedLhs;
    const bool headIsOurs = (c.m_failedRhs != nullptr);
    if (!H) { printf("NO HEAD OBJECT\n"); return 0; }
    Serializer& other = headIsOurs ? sg : so;
    std::vector<const BaseClass*> cands;
    for (auto& kv : other.AllObjects()) {
        const BaseClass* Y = kv.first;
        if (!Y || !sameFace(H, Y) || parentPath(H) != parentPath(Y)) continue;
        cands.push_back(Y);
    }
    printf("COUNTERPART CANDIDATES on the %s side: %zu\n",
           headIsOurs ? "golden" : "ours", cands.size());
    for (auto* Y : cands) printf("    %s\n", ident(Y).c_str());
    // A face can repeat (the same typedef reached through two specialisations),
    // so EVERY candidate gets its own table rather than one being picked: the
    // reader sees the whole ambiguity instead of a guess.
    if (cands.empty()) {
        if (headIsOurs) table(nullptr, H, "head is OURS, no counterpart");
        else table(H, nullptr, "head is GOLDEN, no counterpart");
    }
    for (auto* C : cands) {
        char tag[200];
        snprintf(tag, sizeof tag, "head is %s, counterpart #%u",
                 headIsOurs ? "OURS" : "GOLDEN", C->UhdmId());
        if (headIsOurs) table(C, H, tag);
        else table(H, C, tag);
    }
    return 0;
}
