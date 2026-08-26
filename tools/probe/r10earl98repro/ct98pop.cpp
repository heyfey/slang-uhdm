// r10earl98 -- THE POPULATION COUNTER.  One line per database PAIR.
// MEASUREMENT ONLY; the official uhdm-cmp is the judge.
// LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
//
// SHAPE (golden side, defined BEFORE the law was written):
//   a cont_assign parented at a GEN_SCOPE whose Lhs is a bare `ref_obj`, whose
//   Rhs is an `operation`, and whose Lhs `Actual_group` points at an object
//   that is NOT inside that gen scope -- the signature of the clone
//   `UhdmWriter::writeCont_assign` takes when `bindVariable` answers.
//   In such a cont_assign golden's OTHER refs carry NO `Actual_group`.
//
// COLUMNS
//   SHAPE      golden cont_assigns of that shape
//   SHAPEREF   golden non-Lhs bare refs inside them (the law's own cells)
//   FIX        of those, the ones OURS binds and golden does not
//   AWAY       gen-scope cont_assign refs golden BINDS and ours does not
//              (over the whole gen-scope universe, not just the shape)
//
// build: g++ -O2 -std=c++17 ct98pop.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct98pop
// usage: ct98pop <golden.uhdm> <ours.uhdm>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <string>
#include <map>
#include <vector>
using namespace UHDM;

static std::string fullOf(const BaseClass* o) {
    if (!o) return "";
    if (const scope* x = any_cast<const scope*>(o)) return std::string(x->VpiFullName());
    if (const variables* x = any_cast<const variables*>(o)) return std::string(x->VpiFullName());
    if (const nets* x = any_cast<const nets*>(o)) return std::string(x->VpiFullName());
    if (const ref_obj* x = any_cast<const ref_obj*>(o)) return std::string(x->VpiFullName());
    return "";
}
static std::string span(const BaseClass* o) {
    char b[64];
    snprintf(b, sizeof b, "%u:%u-%u:%u", o->VpiLineNo(), (unsigned)o->VpiColumnNo(),
             o->VpiEndLineNo(), (unsigned)o->VpiEndColumnNo());
    return b;
}
// key -> bound?   (key identical to ct98cen's)
struct Row { bool bound; bool shapeRef; };
static void scan(const char* file, std::map<std::string, std::vector<Row>>& out,
                 long* shape, long* shaperef) {
    Serializer s;
    const std::vector<vpiHandle> h = s.Restore(std::string(file));
    if (h.empty()) return;
    std::map<const cont_assign*, const BaseClass*> caScope;
    std::map<const cont_assign*, bool> caShape;
    for (const auto& [obj, id] : s.AllObjects()) {
        if (!obj || obj->UhdmType() != uhdmcont_assign) continue;
        const BaseClass* p = obj->VpiParent();
        if (!p || p->UhdmType() != uhdmgen_scope) continue;
        const cont_assign* ca = (const cont_assign*)obj;
        caScope[ca] = p;
        bool sh = false;
        const expr* l = ca->Lhs();
        const expr* r = ca->Rhs();
        if (l && l->UhdmType() == uhdmref_obj && r && r->UhdmType() == uhdmoperation) {
            const any* a = ((const ref_obj*)l)->Actual_group();
            if (a) {
                // is the target inside THIS gen scope?
                const BaseClass* q = a->VpiParent();
                bool inside = false;
                for (int d = 0; d < 12 && q; d++) {
                    if (q == p) { inside = true; break; }
                    q = q->VpiParent();
                }
                sh = !inside;
            }
        }
        caShape[ca] = sh;
        if (sh && shape) (*shape)++;
    }
    for (const auto& [obj, id] : s.AllObjects()) {
        if (!obj) continue;
        const ref_obj* r = any_cast<const ref_obj*>(obj);
        if (!r) continue;
        const BaseClass* p = r->VpiParent();
        const cont_assign* ca = nullptr;
        int depth = 0;
        for (; depth < 40 && p; depth++) {
            if (p->UhdmType() == uhdmcont_assign) { ca = (const cont_assign*)p; break; }
            p = p->VpiParent();
        }
        if (!ca) continue;
        auto it = caScope.find(ca);
        if (it == caScope.end()) continue;
        bool isLhs = (ca->Lhs() == (const expr*)r);
        const char* slot = isLhs ? "Lhs"
                         : (ca->Rhs() == (const expr*)r) ? "Rhs" : "deep";
        char key[1400];
        snprintf(key, sizeof key, "%s|%s|%s|%s|%s|%s|d%d",
                 fullOf(it->second).c_str(), span(ca).c_str(),
                 std::string(UhdmName(r->UhdmType())).c_str(),
                 std::string(r->VpiName()).c_str(), span(r).c_str(), slot, depth);
        bool shapeRef = caShape[ca] && !isLhs && r->UhdmType() == uhdmref_obj;
        if (shapeRef && shaperef) (*shaperef)++;
        out[key].push_back({r->Actual_group() != nullptr, shapeRef});
    }
}
int main(int argc, char** argv) {
    if (argc < 3) { fprintf(stderr, "usage: ct98pop <golden> <ours>\n"); return 2; }
    std::map<std::string, std::vector<Row>> G, O;
    long shape = 0, shaperef = 0;
    scan(argv[1], G, &shape, &shaperef);
    scan(argv[2], O, nullptr, nullptr);
    long fix = 0, away = 0;
    bool detail = (argc > 3);
    for (auto& [k, gv] : G) {
        auto it = O.find(k);
        if (it == O.end()) continue;
        auto& ov = it->second;
        size_t n = gv.size() < ov.size() ? gv.size() : ov.size();
        // multiset over the payload: count golden-unbound vs ours-bound
        long gU = 0, gB = 0, oU = 0, oB = 0;
        bool anyShape = false;
        for (size_t i = 0; i < gv.size(); i++) { (gv[i].bound ? gB : gU)++; if (gv[i].shapeRef) anyShape = true; }
        for (size_t i = 0; i < ov.size(); i++) (ov[i].bound ? oB : oU)++;
        (void)n;
        long f = 0, a = 0;
        if (anyShape && oB > gB) f = oB - gB;
        if (gB > oB) a = gB - oB;
        fix += f; away += a;
        if (detail && (f || a))
            printf("  %s F=%ld A=%ld gB=%ld gU=%ld oB=%ld oU=%ld\n", k.c_str(), f, a, gB, gU, oB, oU);
    }
    printf("SHAPE=%ld SHAPEREF=%ld FIX=%ld AWAY=%ld\n", shape, shaperef, fix, away);
    return 0;
}
