// r10earl106 -- THE OWNER FINDER, r10earl105's own106.cpp with ONE addition:
// the target may be named by `id:<UhdmId>` as well as by span, because THIS
// pass's head is a LOCATION-LESS constant and a span cannot name it.
//
// MEASUREMENT ONLY.  The official ~/git-repos/UHDM/build/bin/uhdm-cmp is the
// sole acceptance judge.
//
// The head print names the OBJECT, not who holds it, and on this pass the LHS's
// `vpiParent` is DELIBERATELY MISLEADING: Surelog's substituted constant keeps
// the `param_assign` it was cloned from as its parent
// (CompileExpression.cpp:2951 `result->VpiParent(param_ass)`), so the dump shows
// the head under a `param_assign` fifty lines away from the assignment that
// actually holds it.  This walks the WHOLE arena for every object whose
// `Operands()` / select / call-argument VECTOR CONTAINS the named object, and
// resolves the chain up to the enclosing cont_assign and its scope.  A VECTOR
// container and a SINGULAR one are reported differently, because the judge
// reads them differently (RESUME.md section 9: the VECTOR overload sets BOTH
// containers on a size mismatch).
//
// build:
//   g++ -O2 -std=c++17 own106.cpp -I ~/.local/include \
//       -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o own106
// usage:
//   own106 <db.uhdm> <line:col-endline:endcol> [--kind constant|ref_obj]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <algorithm>
#include <cstdio>
#include <cstring>
#include <cstdlib>
#include <string>
#include <variant>
#include <vector>

using namespace UHDM;

static std::string spanOf(const BaseClass* o) {
    if (!o) return "<null>";
    char b[128];
    snprintf(b, sizeof b, "%u:%u-%u:%u", o->VpiLineNo(), (unsigned)o->VpiColumnNo(),
             o->VpiEndLineNo(), (unsigned)o->VpiEndColumnNo());
    return b;
}
static std::string nameOf(const BaseClass* o) {
    if (!o) return "";
    auto pv = o->GetVpiPropertyValue(vpiFullName);
    if (std::holds_alternative<const char*>(pv)) {
        const char* p = std::get<const char*>(pv);
        if (p && *p) return p;
    }
    return std::string(o->VpiName());
}
static void chain(const BaseClass* o, const char* tag) {
    printf("%s", tag);
    int d = 0;
    for (const BaseClass* p = o; p && d < 12; p = p->VpiParent(), d++)
        printf("%*s> %s %s %s\n", d * 2 + 2, "",
               std::string(UhdmName(p->UhdmType())).c_str(),
               spanOf(p).c_str(), nameOf(p).c_str());
}

int main(int argc, char** argv) {
    if (argc < 3) {
        fprintf(stderr, "usage: own106 <db.uhdm> <l:c-l:c> [--kind K]\n");
        return 2;
    }
    std::string want(argv[2]);
    std::string kind;
    for (int i = 3; i + 1 < argc; i++)
        if (!strcmp(argv[i], "--kind")) kind = argv[i + 1];
    Serializer s;
    if (s.Restore(std::string(argv[1])).empty()) {
        fprintf(stderr, "RESTORE_FAILED %s\n", argv[1]);
        return 3;
    }
    std::vector<const BaseClass*> all;
    for (const auto& [o, id] : s.AllObjects())
        if (o) all.push_back(o);
    std::sort(all.begin(), all.end(), [](const BaseClass* a, const BaseClass* b) {
        return a->UhdmId() != b->UhdmId() ? a->UhdmId() < b->UhdmId() : a < b;
    });
    std::vector<const BaseClass*> targets;
    for (const BaseClass* o : all)
        if ((want.rfind("id:", 0) == 0
                 ? (o->UhdmId() == (unsigned)atoi(want.c_str() + 3))
                 : (spanOf(o) == want)) &&
            (kind.empty() || std::string(UhdmName(o->UhdmType())) == kind))
            targets.push_back(o);
    printf("TARGETS at %s%s%s: %zu\n", want.c_str(),
           kind.empty() ? "" : " kind=", kind.c_str(), targets.size());
    for (const BaseClass* t : targets) {
        printf("\n== TARGET %s id:%u %s\n",
               std::string(UhdmName(t->UhdmType())).c_str(), t->UhdmId(),
               nameOf(t).c_str());
        chain(t, "  vpiParent chain (what the DUMP shows):\n");
        int nvec = 0, nsing = 0;
        for (const BaseClass* o : all) {
            // VECTOR containers
            if (auto* op = any_cast<const operation*>((const any*)o))
                if (op->Operands())
                    for (size_t i = 0; i < op->Operands()->size(); i++)
                        if ((const BaseClass*)(*op->Operands())[i] == t) {
                            nvec++;
                            printf("  VECTOR  operation op=%d %s  Operands[%zu]\n",
                                   op->VpiOpType(), spanOf(op).c_str(), i);
                            chain(op, "    holder chain:\n");
                        }
            if (auto* vs = any_cast<const var_select*>((const any*)o))
                if (vs->Exprs())
                    for (size_t i = 0; i < vs->Exprs()->size(); i++)
                        if ((const BaseClass*)(*vs->Exprs())[i] == t) {
                            nvec++;
                            printf("  VECTOR  var_select %s Exprs[%zu]\n",
                                   spanOf(vs).c_str(), i);
                            chain(vs, "    holder chain:\n");
                        }
            if (auto* fc = any_cast<const sys_func_call*>((const any*)o))
                if (fc->Tf_call_args())
                    for (size_t i = 0; i < fc->Tf_call_args()->size(); i++)
                        if ((const BaseClass*)(*fc->Tf_call_args())[i] == t) {
                            nvec++;
                            printf("  VECTOR  sys_func_call %s args[%zu]\n",
                                   spanOf(fc).c_str(), i);
                            chain(fc, "    holder chain:\n");
                        }
            // SINGULAR containers
            if (auto* ca = any_cast<const cont_assign*>((const any*)o)) {
                if ((const BaseClass*)ca->Rhs() == t) {
                    nsing++;
                    printf("  SINGULAR cont_assign %s Rhs\n", spanOf(ca).c_str());
                    chain(ca, "    holder chain:\n");
                }
                if ((const BaseClass*)ca->Lhs() == t) {
                    nsing++;
                    printf("  SINGULAR cont_assign %s Lhs\n", spanOf(ca).c_str());
                }
            }
            if (auto* bs = any_cast<const bit_select*>((const any*)o))
                if ((const BaseClass*)bs->VpiIndex() == t) {
                    nsing++;
                    printf("  SINGULAR bit_select %s Index\n", spanOf(bs).c_str());
                    chain(bs, "    holder chain:\n");
                }
            if (auto* ps = any_cast<const part_select*>((const any*)o)) {
                if ((const BaseClass*)ps->Left_range() == t ||
                    (const BaseClass*)ps->Right_range() == t) {
                    nsing++;
                    printf("  SINGULAR part_select %s bound\n", spanOf(ps).c_str());
                    chain(ps, "    holder chain:\n");
                }
            }
            if (auto* ip = any_cast<const indexed_part_select*>((const any*)o))
                if ((const BaseClass*)ip->Base_expr() == t ||
                    (const BaseClass*)ip->Width_expr() == t) {
                    nsing++;
                    printf("  SINGULAR indexed_part_select %s\n",
                           spanOf(ip).c_str());
                    chain(ip, "    holder chain:\n");
                }
            if (auto* pa = any_cast<const param_assign*>((const any*)o))
                if ((const BaseClass*)pa->Rhs() == t) {
                    nsing++;
                    printf("  SINGULAR param_assign %s Rhs\n", spanOf(pa).c_str());
                    chain(pa, "    holder chain:\n");
                }
        }
        printf("  containers: VECTOR=%d SINGULAR=%d\n", nvec, nsing);
    }
    return 0;
}
