// r10earl109 -- THE OWNER FINDER for a RANGE-BOUND constant.
//
// MEASUREMENT ONLY.  The official ~/git-repos/UHDM/build/bin/uhdm-cmp is the
// sole acceptance judge.  LHS is ALWAYS golden; RHS is ALWAYS ours.
//
// r10earl106/107/108's own10N.cpp answers "who holds this object" for operands,
// selects and cont_assign/param_assign edges.  THIS pass's head is a
// RANGE BOUND, and the chain the judge walks to reach it is
//     <carrier> -> ref_typespec -> <typespec> -> Ranges()[i] -> Left/Right_expr
// so the finder has to climb three edges the earlier ones never look at:
//   (1) every `range` whose Left_expr / Right_expr IS the target,
//   (2) every object whose `Ranges()` VECTOR contains that range -- the
//       typespec, but also an array_net / array_var / io_decl / net / variable
//       that carries its own dimension list,
//   (3) every `ref_typespec` whose `Actual_typespec()` is that typespec, and
//       that ref's own parent -- because a typespec is SHARED between the
//       instance copy and the declaration copy and the dump only ever prints
//       the first holder it reaches.
// (3) is the one that matters: RESUME.md section 9 records that no generated
// Compare reads VpiParent, so "who owns it" cannot be read off the dump's
// parent chain -- it has to be enumerated.
//
// build:
//   g++ -O2 -std=c++17 own109.cpp -I ~/.local/include \
//       -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o own109
// usage:
//   own109 <db.uhdm> id:<UhdmId>              -- name the object by id
//   own109 <db.uhdm> <l:c-l:c> [--kind constant]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <algorithm>
#include <cstdio>
#include <cstring>
#include <cstdlib>
#include <set>
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
static std::string fileOf(const BaseClass* o) {
    if (!o) return "";
    std::string f(o->VpiFile());
    auto p = f.rfind('/');
    return p == std::string::npos ? f : f.substr(p + 1);
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
static std::string kindOf(const BaseClass* o) {
    return o ? std::string(UhdmName(o->UhdmType())) : "<null>";
}
static void chain(const BaseClass* o, const char* tag, int indent = 2) {
    printf("%s", tag);
    int d = 0;
    for (const BaseClass* p = o; p && d < 14; p = p->VpiParent(), d++)
        printf("%*s> %s id:%u %s %s %s\n", d * 2 + indent, "",
               kindOf(p).c_str(), p->UhdmId(), fileOf(p).c_str(),
               spanOf(p).c_str(), nameOf(p).c_str());
}
// Compare-visible payload of an expr, in the order the generated Compares read
// it (BaseClass: VpiType/VpiName/VpiDefName; expr: VpiDecompile/VpiSize/
// Typespec; constant: VpiConstType).  Never the span, never the fullname.
static std::string payload(const BaseClass* o) {
    if (!o) return "<null>";
    std::string r = kindOf(o);
    if (auto* e = any_cast<const expr*>((const any*)o)) {
        r += " dc=\"" + std::string(e->VpiDecompile()) + "\"";
        r += " sz=" + std::to_string(e->VpiSize());
        r += " val=" + std::string(e->VpiValue());
        const ref_typespec* rt = e->Typespec();
        const typespec* at = rt ? rt->Actual_typespec() : nullptr;
        r += " ts=" + (at ? kindOf(at) : std::string("NONE"));
        if (at) {
            r += "#" + std::to_string(at->UhdmId());
            if (auto* it = any_cast<const int_typespec*>((const any*)at))
                r += it->VpiSigned() ? " SIGNED" : " unsigned";
            if (auto* it2 = any_cast<const int_typespec*>((const any*)at))
                r += " tsval=\"" + std::string(it2->VpiValue()) + "\"";
            r += " tsspan=" + spanOf(at);
        }
    }
    if (auto* c = any_cast<const constant*>((const any*)o))
        r += " ct=" + std::to_string(c->VpiConstType());
    if (auto* ro = any_cast<const ref_obj*>((const any*)o))
        r += " actual=" + kindOf((const BaseClass*)ro->Actual_group());
    return r;
}

int main(int argc, char** argv) {
    if (argc < 3) {
        fprintf(stderr, "usage: own109 <db.uhdm> <id:N|l:c-l:c> [--kind K]\n");
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
    printf("ARENA %zu objects\n", all.size());
    std::vector<const BaseClass*> targets;
    for (const BaseClass* o : all)
        if ((want.rfind("id:", 0) == 0
                 ? (o->UhdmId() == (unsigned)atoi(want.c_str() + 3))
                 : (spanOf(o) == want)) &&
            (kind.empty() || kindOf(o) == kind))
            targets.push_back(o);
    printf("TARGETS at %s%s%s: %zu\n", want.c_str(),
           kind.empty() ? "" : " kind=", kind.c_str(), targets.size());

    for (const BaseClass* t : targets) {
        printf("\n== TARGET %s id:%u %s %s\n", kindOf(t).c_str(), t->UhdmId(),
               fileOf(t).c_str(), spanOf(t).c_str());
        printf("   payload: %s\n", payload(t).c_str());
        chain(t, "   vpiParent chain (what the DUMP shows):\n");

        // (1) RANGE holders
        std::set<const BaseClass*> rngs;
        for (const BaseClass* o : all)
            if (auto* rg = any_cast<const range*>((const any*)o)) {
                if ((const BaseClass*)rg->Left_expr() == t) {
                    printf("   RANGE  id:%u %s Left_expr   (right=%s)\n",
                           rg->UhdmId(), spanOf(rg).c_str(),
                           payload((const BaseClass*)rg->Right_expr()).c_str());
                    rngs.insert(o);
                }
                if ((const BaseClass*)rg->Right_expr() == t) {
                    printf("   RANGE  id:%u %s Right_expr  (left=%s)\n",
                           rg->UhdmId(), spanOf(rg).c_str(),
                           payload((const BaseClass*)rg->Left_expr()).c_str());
                    rngs.insert(o);
                }
            }
        // (2) Ranges() VECTOR holders of those ranges
        std::set<const BaseClass*> tss;
        int nvec = 0;
        for (const BaseClass* rg : rngs) {
            for (const BaseClass* o : all) {
                const VectorOfrange* v = nullptr;
                if (auto* lt = any_cast<const logic_typespec*>((const any*)o)) v = lt->Ranges();
                else if (auto* bt = any_cast<const bit_typespec*>((const any*)o)) v = bt->Ranges();
                else if (auto* at = any_cast<const array_typespec*>((const any*)o)) v = at->Ranges();
                else if (auto* pt = any_cast<const packed_array_typespec*>((const any*)o)) v = pt->Ranges();
                else if (auto* it = any_cast<const int_typespec*>((const any*)o)) v = it->Ranges();
                else if (auto* ln = any_cast<const logic_net*>((const any*)o)) v = ln->Ranges();
                else if (auto* lv = any_cast<const logic_var*>((const any*)o)) v = lv->Ranges();
                else if (auto* an = any_cast<const array_net*>((const any*)o)) v = an->Ranges();
                else if (auto* av = any_cast<const array_var*>((const any*)o)) v = av->Ranges();
                else if (auto* pa = any_cast<const parameter*>((const any*)o)) v = pa->Ranges();
                else if (auto* io = any_cast<const io_decl*>((const any*)o)) v = io->Ranges();
                if (!v) continue;
                for (size_t i = 0; i < v->size(); i++)
                    if ((const BaseClass*)(*v)[i] == rg) {
                        nvec++;
                        printf("   RANGES-HOLDER %s id:%u %s %s  Ranges[%zu]\n",
                               kindOf(o).c_str(), o->UhdmId(), spanOf(o).c_str(),
                               nameOf(o).c_str(), i);
                        chain(o, "     holder chain:\n", 5);
                        tss.insert(o);
                    }
            }
        }
        // (3) every ref_typespec pointing at those typespecs, and its parent
        int nref = 0;
        for (const BaseClass* ts0 : tss) {
            auto* ts = any_cast<const typespec*>((const any*)ts0);
            if (!ts) continue;
            for (const BaseClass* o : all)
                if (auto* rt = any_cast<const ref_typespec*>((const any*)o))
                    if ((const BaseClass*)rt->Actual_typespec() == ts0) {
                        nref++;
                        const BaseClass* p = rt->VpiParent();
                        printf("   REF_TS id:%u fullname=\"%s\"  <- %s id:%u %s %s %s\n",
                               rt->UhdmId(), nameOf(rt).c_str(),
                               kindOf(p).c_str(), p ? p->UhdmId() : 0,
                               fileOf(p).c_str(), spanOf(p).c_str(),
                               nameOf(p).c_str());
                        if (p) chain(p->VpiParent(), "     carrier chain:\n", 5);
                    }
        }
        printf("   containers: RANGES=%zu RANGES-HOLDERS=%d REF_TS=%d\n",
               rngs.size(), nvec, nref);
    }
    return 0;
}
