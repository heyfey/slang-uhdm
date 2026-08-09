// r10uvm28e — CUT-BISECTION: name the OWNER of a divergent scalar POINTER.
//
// `CompareContext` records `m_failedLhs`/`m_failedRhs` but never the object
// that HELD the differing member, and for a scalar pointer that is null on one
// side it records only ONE of the two (BaseClass.h:191-197).  So a report like
// "L <null>  R string_var 'v'" says an extra pointer exists somewhere on our
// side and nothing about where.  vpiParent does NOT answer it either: the
// holder of a pointer is frequently not the pointee's parent.
//
// The bisection exploits `m_visited`, which is keyed on the LHS (golden)
// object and short-circuits a whole subtree: cutting the OWNER (or any of its
// ancestors) makes the failure vanish, cutting anything else does not.  Walk
// golden's objects, cut one at a time, and the DEEPEST cut that clears the
// failure is the owner.
//
//   r10uvm28e <golden.uhdm> <ours.uhdm> <className|-> <tfName>
#include <uhdm/Serializer.h>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <algorithm>
#include <filesystem>
#include <iostream>
#include <map>
#include <string>
#include <vector>
using namespace UHDM;

static std::string d1(const BaseClass* o) {
    if (!o) return "<null>";
    return std::string(UhdmName(o->UhdmType())) + " '" + std::string(o->VpiName()) +
           "' " + std::to_string(o->VpiLineNo()) + ":" +
           std::to_string(o->VpiColumnNo()) + " #" + std::to_string(o->UhdmId());
}

static const task_func* findTf(const design* d, const std::string& cls,
                               const std::string& tf) {
    for (auto* v : {d->AllPackages(), d->TopPackages()}) {
        if (!v) continue;
        for (auto* p : *v) {
            if (cls == "-" && p->Task_funcs())
                for (auto* f : *p->Task_funcs())
                    if (std::string(f->VpiName()) == tf) return f;
            if (!p->Class_defns()) continue;
            for (auto* c : *p->Class_defns()) {
                if (cls != "-" && std::string(c->VpiName()) != cls) continue;
                if (!c->Task_funcs()) continue;
                for (auto* f : *c->Task_funcs())
                    if (std::string(f->VpiName()) == tf) return f;
            }
        }
    }
    return nullptr;
}

int main(int argc, char** argv) {
    Serializer sa, sb;
    auto ha = sa.Restore(std::filesystem::path(argv[1]));
    auto hb = sb.Restore(std::filesystem::path(argv[2]));
    const design* da = (const design*)((uhdm_handle*)ha[0])->object;
    const design* db = (const design*)((uhdm_handle*)hb[0])->object;
    const task_func* ga = findTf(da, argv[3], argv[4]);
    const task_func* gb = findTf(db, argv[3], argv[4]);
    if (!ga || !gb) {
        std::cerr << "not found: " << (ga ? "ours" : "golden") << "\n";
        return 1;
    }
    auto run = [&](const BaseClass* cut, const BaseClass** fl,
                   const BaseClass** fr) {
        CompareContext ctx;
        if (cut) ctx.m_visited.insert(cut);
        int32_t r = ga->Compare(gb, &ctx);
        *fl = ctx.m_failedLhs;
        *fr = ctx.m_failedRhs;
        return r;
    };
    const BaseClass *fl = nullptr, *fr = nullptr;
    int32_t r0 = run(nullptr, &fl, &fr);
    std::cout << "BASE r=" << r0 << "\n  L " << d1(fl) << "\n  R " << d1(fr)
              << "\n";
    if (r0 == 0) return 0;

    // Depth of every golden object under the task_func, by vpiParent chain.
    std::map<const BaseClass*, int> depth;
    for (auto& [o, id] : sa.AllObjects()) {
        int n = 0;
        const BaseClass* p = o;
        while (p && n < 64) {
            if (p == ga) {
                depth[o] = n;
                break;
            }
            p = p->VpiParent();
            ++n;
        }
    }
    std::cout << "subtree objects: " << depth.size() << "\n";
    std::vector<std::pair<int, const BaseClass*>> cands;
    for (auto& [o, n] : depth) cands.push_back({n, o});
    std::sort(cands.begin(), cands.end(),
              [](auto& a, auto& b) { return a.first > b.first; });
    for (auto& [n, o] : cands) {
        const BaseClass *l2 = nullptr, *r2 = nullptr;
        int32_t r = run(o, &l2, &r2);
        if (r != r0 || l2 != fl || r2 != fr)
            std::cout << "CUT depth=" << n << " " << d1(o) << "  -> r=" << r
                      << " L " << d1(l2) << " R " << d1(r2) << "\n";
    }
    return 0;
}
