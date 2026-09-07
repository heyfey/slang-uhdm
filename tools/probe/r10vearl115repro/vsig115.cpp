// r10vearl115 -- sig115 PLUS THE OWNING INSTANCE PATH.  MEASUREMENT ONLY.
//
// WHY: r10earl115's `sig115` key carries no instance path, so every copy of a
// cell across every instance of a module collapses into ONE key whose payload
// is a SET.  An arm that instantiates the same child several ways (the
// `genAbove` fence's whole point) therefore cannot say WHICH instance moved.
// This adds the parent chain -- the gen-scope / instance names above the
// hier_path -- to the row, and prints the payload so a MULTISET scorer can
// count copies instead of collapsing them.
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <uhdm/UhdmListener.h>
#include <cstdio>
#include <string>
#include <vector>
using namespace UHDM;
static std::string kindOf(const BaseClass* o) {
    return o ? std::string(UhdmName(o->UhdmType())) : "<null>";
}
static const any* actOf(const BaseClass* e) {
    if (!e) return nullptr;
    switch (e->UhdmType()) {
        case uhdmref_obj: return ((const ref_obj*)e)->Actual_group();
        case uhdmref_var: return ((const ref_var*)e)->Actual_group();
        case uhdmbit_select: return ((const bit_select*)e)->Actual_group();
        case uhdmvar_select: return ((const var_select*)e)->Actual_group();
        default: return nullptr;
    }
}
static const char* posClass(size_t i, size_t n) {
    if (n == 1) return "only";
    if (i == 0) return "first";
    if (i + 1 == n) return "trail";
    return "mid";
}
// THE INSTANCE PATH: every module_inst / interface_inst / gen_scope above the
// hier_path, innermost last.  A gen_scope's own VpiName carries its index, so
// `gen_inst[0]` and `gen_inst[1]` are DIFFERENT keys -- which is exactly what
// the fence arms need.  The DESIGN-level name is dropped (the two producers
// label the definition listing's root differently; RESUME.md section 9).
static std::string instPath(const BaseClass* hp) {
    std::vector<std::string> parts;
    const BaseClass* p = hp ? hp->VpiParent() : nullptr;
    for (int d = 0; d < 48 && p; d++) {
        auto t = p->UhdmType();
        if (t == uhdmmodule_inst || t == uhdminterface_inst ||
            t == uhdmgen_scope) {
            std::string n(p->VpiName());
            if (n.empty()) n = "<anon>";
            parts.push_back(std::string(UhdmName(t)).substr(4) + ":" + n);
        }
        p = p->VpiParent();
    }
    std::string s;
    for (size_t i = parts.size(); i-- > 0;) {
        if (!s.empty()) s += "/";
        s += parts[i];
    }
    return s.empty() ? "<top>" : s;
}
static std::string carrierOf(const BaseClass* hp) {
    const BaseClass* p = hp ? hp->VpiParent() : nullptr;
    if (!p) return "<none>";
    std::string s = kindOf(p);
    if (auto* op = any_cast<const operation*>(p))
        s += "/op" + std::to_string(op->VpiOpType());
    if (auto* q = p->VpiParent()) s += "<-" + kindOf(q);
    return s;
}
class HpWalk final : public UhdmListener {
 public:
    std::string tag;
    void enterHier_path(const hier_path* const hp) final {
        auto* es = hp->Path_elems();
        size_t n = es ? es->size() : 0;
        char span[128];
        snprintf(span, sizeof span, "%u:%u-%u:%u", hp->VpiLineNo(),
                 (unsigned)hp->VpiColumnNo(), hp->VpiEndLineNo(),
                 (unsigned)hp->VpiEndColumnNo());
        std::string ip = instPath(hp);
        for (size_t i = 0; i < n; i++) {
            const BaseClass* e = es->at(i);
            const any* a = actOf(e);
            printf("VROW\t%s\t%s\tnm=%s\tidx=%zu/%zu\tpos=%s\tek=%s\tIP=%s\tCAR=%s\tACT=%s/%s\n",
                   tag.c_str(), span, std::string(hp->VpiName()).c_str(), i, n,
                   posClass(i, n), kindOf(e).c_str(), ip.c_str(),
                   carrierOf(hp).c_str(), kindOf(a).c_str(),
                   a ? std::string(a->VpiName()).c_str() : "");
        }
    }
};
int main(int argc, char** argv) {
    if (argc < 3) { fprintf(stderr, "usage: vsig115 <db> <tag>\n"); return 2; }
    Serializer s;
    auto h = s.Restore(std::string(argv[1]));
    if (h.empty()) { printf("VCENRC 3\n"); return 3; }
    const design* d = (const design*)((const uhdm_handle*)h[0])->object;
    HpWalk w;
    w.tag = argv[2];
    w.listenDesign(d);
    printf("VCENRC 0\n");
    return 0;
}
