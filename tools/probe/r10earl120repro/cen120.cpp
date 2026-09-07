// r10earl120 — THE CENSUS of § `paPaCopyTsInstance120`'s cell:
// the `int_typespec` that a param-substitution constant's `ref_typespec`
// points at, and the `vpiInstance` home that typespec carries.
//
// MEASUREMENT ONLY.  `uhdm-cmp` is the sole acceptance judge.
//
// THE CELL.  Surelog answers a bare read of a parameter that has a
// `param_assign` on the enclosing component with
// `UHDM::clone_tree(param_ass->Rhs())` (CompileExpression.cpp:2918-2975).
// `typespec::DeepCopy` (UHDM/build/generated/src/typespec.cpp:72-79) copies
// the source typespec's `Instance()` into the clone.  So every substituted
// constant carries a PER-READ typespec object whose `vpiInstance` is the
// home of the parameter's DECLARATION typespec — a package for a package
// parameter, null for a module-local one.  § genCaTopLoopParamPaCopy105
// reproduces that clone by minting the typespec field by field.
//
// KEY (compare-visible only, RESUME.md section 9): our objects carry an EMPTY
// `VpiFile`, so the file is NOT in the key.  The key is
//     <home instance fullname> | <constant span> | <typespec span> | <signed>
// PAYLOAD: the package the `Instance` edge lands on, spelled `name ROLE`
// where ROLE is `All[i]`/`Top[i]` from `design::AllPackages`/`TopPackages` —
// never a pointer, because the two producers mint different objects.
// A diagnostic `SRC` row records every PACKAGE PARAMETER's own declaration
// typespec (span + signed + its instance), which is what `predict120.py`
// joins against to decide, from the PRISTINE database alone, which null
// copies have an instanced source and must therefore move.
//
// build: g++ -O2 -std=c++17 cen120.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o cen120
// usage: cen120 <db.uhdm>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <cstdio>
#include <map>
#include <string>

using namespace UHDM;

static std::string kindOf(const BaseClass* o) {
    return o ? std::string(UhdmName(o->UhdmType())) : std::string("<null>");
}
static std::string span(const BaseClass* o) {
    char b[96];
    snprintf(b, sizeof b, "%u:%u-%u:%u", o->VpiLineNo(), (unsigned)o->VpiColumnNo(),
             o->VpiEndLineNo(), (unsigned)o->VpiEndColumnNo());
    return b;
}
// The nearest enclosing instance-ish owner, named by VpiFullName when it has
// one (our hier_paths and some minted objects have none — RESUME.md section 9).
static std::string homeOf(const BaseClass* o) {
    for (const BaseClass* p = o; p; p = p->VpiParent()) {
        const std::string k = kindOf(p);
        if (k == "module_inst" || k == "interface_inst" || k == "package" ||
            k == "program" || k == "class_defn") {
            std::string fn;
            if (const scope* sc = any_cast<const scope*>((const any*)p))
                fn = std::string(sc->VpiFullName());
            if (fn.empty()) fn = std::string(p->VpiName());
            return k + ":" + fn;
        }
    }
    return "<nohome>";
}

int main(int argc, char** argv) {
    if (argc < 2) { fprintf(stderr, "usage: cen120 <db.uhdm>\n"); return 2; }
    Serializer s;
    auto h = s.Restore(std::string(argv[1]));
    if (h.empty()) { printf("CENRC 3\n"); return 3; }
    const design* d = (const design*)((const uhdm_handle*)h[0])->object;

    std::map<const BaseClass*, std::string> role;
    if (d->AllPackages())
        for (size_t i = 0; i < d->AllPackages()->size(); i++)
            role[d->AllPackages()->at(i)] += "All[" + std::to_string(i) + "]";
    if (d->TopPackages())
        for (size_t i = 0; i < d->TopPackages()->size(); i++)
            role[d->TopPackages()->at(i)] += "Top[" + std::to_string(i) + "]";

    // THE JUDGE-VISIBLE payload is the package the edge NAMES.  `Compare`
    // follows `typespec::Instance` into `package::Compare`, which reads
    // VpiName/VpiDefName and the package's containers -- never which of
    // `design::AllPackages` / `design::TopPackages` listed the object.  So the
    // SCORED payload is the name; the vector ROLE goes on a separate
    // diagnostic `ROLECELL` row, so a role divergence is still counted and
    // visible instead of being hidden by the choice of payload.
    auto payOf = [&](const instance* in) {
        if (!in) return std::string("<null>");
        return kindOf(in) + ":" + std::string(in->VpiName());
    };
    auto roleOf = [&](const instance* in) {
        if (!in) return std::string("<null>");
        std::string r = kindOf(in) + ":" + std::string(in->VpiName());
        if (role.count(in)) r += " " + role[(const BaseClass*)in];
        else r += " (unlisted)";
        return r;
    };

    std::map<std::string, std::map<std::string, int>> cells, roles, srcs;
    for (const auto& [obj, id] : s.AllObjects()) {
        const typespec* t = any_cast<const typespec*>((const any*)obj);
        if (!t) continue;
        const BaseClass* p = obj->VpiParent();
        if (!p) continue;
        if (kindOf(p) == "ref_typespec") {
            const BaseClass* g = p->VpiParent();
            if (!g || kindOf(g) != "constant") continue;
            // THE CELL: a constant's own typespec object.
            int sg = -1;
            if (const int_typespec* it = any_cast<const int_typespec*>((const any*)obj))
                sg = it->VpiSigned() ? 1 : 0;
            const std::string ck = homeOf(obj) + "|" + span(g) + "|" +
                                   kindOf(obj) + "|" + span(obj) + "|s" +
                                   std::to_string(sg);
            cells[ck][payOf(t->Instance())]++;
            roles[ck][roleOf(t->Instance())]++;
        }
        else if (kindOf(p) == "parameter") {
            const BaseClass* g = p->VpiParent();
            if (!g || kindOf(g) != "package") continue;
            // THE SOURCE: a package parameter's declaration typespec.
            int sg = -1;
            if (const int_typespec* it = any_cast<const int_typespec*>((const any*)obj))
                sg = it->VpiSigned() ? 1 : 0;
            srcs[kindOf(obj) + "|" + span(obj) + "|s" + std::to_string(sg)]
                [payOf(t->Instance())]++;
        }
    }
    // One row per (key, payload): the multiset the three-way join needs.
    for (const auto& [k, pm] : cells)
        for (const auto& [pay, n] : pm)
            printf("CELL\t%d\t%s\t%s\n", n, k.c_str(), pay.c_str());
    for (const auto& [k, pm] : roles)
        for (const auto& [pay, n] : pm)
            printf("ROLECELL\t%d\t%s\t%s\n", n, k.c_str(), pay.c_str());
    for (const auto& [k, pm] : srcs)
        for (const auto& [pay, n] : pm)
            printf("SRC\t%d\t%s\t%s\n", n, k.c_str(), pay.c_str());
    printf("CENRC 0\n");
    return 0;
}
