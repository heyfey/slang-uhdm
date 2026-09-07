// r10earl115 -- THE JUDGE, DECODED FIRST, on the PER-ELEMENT BINDING of a
// pattern-carried `hier_path`.
//
// MEASUREMENT ONLY.  The official ~/git-repos/UHDM/build/bin/uhdm-cmp is the
// sole acceptance judge.  LHS is ALWAYS golden; RHS is ALWAYS ours.
//
// Extends r10earl114's own114:
//   * `elems()` now prints EVERY element kind's `Actual_group` (ref_obj,
//     ref_var, bit_select, var_select, part_select, indexed_part_select),
//     with the element's POSITION class (first / middle / trailing) and its
//     kind -- the matrix this pass is keyed on;
//   * MODE `paths`: pair EVERY hier_path in the two databases by span+name and
//     print both sides' per-element binding, so the decode is read over the
//     whole database and not off one head;
//   * MODE `ladder`: mask, on the GOLDEN copy IN MEMORY, first every paired
//     hier_path's `Typespec` (r10earl114's field) and then every paired
//     hier_path's per-element `Actual_group`, re-running the OFFICIAL
//     design::Compare after each so the ladder is READ, never predicted.
//
// The databases on disk are never written.
//
// build:
//   g++ -O2 -std=c++17 own115.cpp -I ~/.local/include \
//       -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o own115
// usage:
//   own115 head   <golden.uhdm> <ours.uhdm> [iters]
//   own115 paths  <golden.uhdm> <ours.uhdm> [nameFilter]
//   own115 ladder <golden.uhdm> <ours.uhdm>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <map>
#include <set>
#include <string>
#include <vector>

using namespace UHDM;

static std::string spanOf(const BaseClass* o) {
    if (!o) return "<null>";
    char b[256];
    std::string f(o->VpiFile());
    auto p = f.rfind('/');
    if (p != std::string::npos) f = f.substr(p + 1);
    snprintf(b, sizeof b, "%s %u:%u-%u:%u", f.c_str(), o->VpiLineNo(),
             (unsigned)o->VpiColumnNo(), o->VpiEndLineNo(),
             (unsigned)o->VpiEndColumnNo());
    return b;
}
static std::string kindOf(const BaseClass* o) {
    return o ? std::string(UhdmName(o->UhdmType())) : "<null>";
}

static std::string tsEdge(const expr* e) {
    if (!e) return "<null>";
    auto* rt = e->Typespec();
    if (!rt) return "<null>";
    std::string s = "ref_typespec(name='" + std::string(rt->VpiName()) +
                    "',dn='" + std::string(rt->VpiDefName()) + "')";
    auto* a = rt->Actual_typespec();
    s += "->" + kindOf(a);
    if (a) s += "('" + std::string(a->VpiName()) + "')";
    return s;
}

// ---------------------------------------------------------------------------
// The FOUR reference kinds a `hier_path` element can be, and their vpiActual.
// `hier_path::Compare` runs the VECTOR SafeCompare over `Path_elems`, so each
// element is compared with its OWN generated Compare -- and `ref_obj::Compare`,
// `ref_var::Compare` and `bit_select::Compare` all read `Actual_group`.
// ---------------------------------------------------------------------------
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
static bool setAct(BaseClass* e, any* a) {
    if (!e) return false;
    switch (e->UhdmType()) {
        case uhdmref_obj: ((ref_obj*)e)->Actual_group(a); return true;
        case uhdmref_var: ((ref_var*)e)->Actual_group(a); return true;
        case uhdmbit_select: ((bit_select*)e)->Actual_group(a); return true;
        case uhdmvar_select: ((var_select*)e)->Actual_group(a); return true;
        default: return false;
    }
}

static std::string payloadShort(const BaseClass* o) {
    if (!o) return "<null>";
    std::string s = kindOf(o);
    if (!o->VpiName().empty()) s += "('" + std::string(o->VpiName()) + "')";
    if (auto* e = any_cast<const expr*>(o)) {
        s += "[sz=" + std::to_string(e->VpiSize()) + "]";
        if (!e->VpiDecompile().empty())
            s += "[dec=" + std::string(e->VpiDecompile()) + "]";
        s += "[ts=" + tsEdge(e) + "]";
    }
    return s;
}

static std::string actBrief(const BaseClass* o) {
    if (!o) return "<null>";
    std::string s = kindOf(o);
    if (!o->VpiName().empty()) s += "('" + std::string(o->VpiName()) + "')";
    // where does the bound object LIVE?  (a typespec_member lives on the
    // struct typespec; a variable/net lives in a scope)
    if (auto* p = o->VpiParent())
        s += "@" + kindOf(p) +
             (p->VpiName().empty() ? "" : "('" + std::string(p->VpiName()) + "')");
    return s;
}

static std::string payload(const BaseClass* o) {
    if (!o) return "<null>";
    std::string s = kindOf(o);
    s += " name='" + std::string(o->VpiName()) + "'";
    if (!o->VpiDefName().empty())
        s += " dn='" + std::string(o->VpiDefName()) + "'";
    if (auto* e = any_cast<const expr*>(o)) {
        if (!e->VpiDecompile().empty())
            s += " dec='" + std::string(e->VpiDecompile()) + "'";
        s += " size=" + std::to_string(e->VpiSize());
        s += " ts=" + tsEdge(e);
    }
    if (auto* c = any_cast<const constant*>(o))
        s += " ct=" + std::to_string(c->VpiConstType());
    if (auto* op = any_cast<const operation*>(o)) {
        s += " optype=" + std::to_string(op->VpiOpType());
        s += " ops=" +
             std::to_string(op->Operands() ? op->Operands()->size() : 0);
    }
    s += "  @" + spanOf(o);
    return s;
}

// POSITION CLASS -- the axis this pass is about.
static const char* posClass(size_t i, size_t n) {
    if (n == 1) return "only";
    if (i == 0) return "first";
    if (i + 1 == n) return "trail";
    return "mid";
}

// The carrier: what OWNS this hier_path, two levels up.
static std::string carrierOf(const BaseClass* hp) {
    std::string s;
    const BaseClass* p = hp ? hp->VpiParent() : nullptr;
    for (int d = 0; d < 3 && p; d++) {
        if (d) s += "<-";
        s += kindOf(p);
        if (auto* op = any_cast<const operation*>(p))
            s += "(op" + std::to_string(op->VpiOpType()) + ")";
        p = p->VpiParent();
    }
    return s.empty() ? "<none>" : s;
}

// The enclosing SCOPE kind and generate depth (r10earl113's axis).
static std::string scopeOf(const BaseClass* hp) {
    const BaseClass* p = hp ? hp->VpiParent() : nullptr;
    int gd = 0;
    for (int d = 0; d < 24 && p; d++) {
        auto t = p->UhdmType();
        if (t == uhdmgen_scope || t == uhdmgen_scope_array) gd++;
        if (t == uhdmmodule_inst || t == uhdminterface_inst ||
            t == uhdmpackage || t == uhdmclass_defn || t == uhdmgen_scope) {
            return std::string(UhdmName(t)) + " gd=" + std::to_string(gd);
        }
        p = p->VpiParent();
    }
    return "?" ;
}

static void elems(const char* tag, const BaseClass* o) {
    auto* hp = any_cast<const hier_path*>(o);
    if (!hp) return;
    size_t n = hp->Path_elems() ? hp->Path_elems()->size() : 0;
    printf("   %s Path_elems (%zu):\n", tag, n);
    if (!n) return;
    size_t i = 0;
    for (auto* e : *hp->Path_elems()) {
        printf("     [%zu:%-5s] %-18s name='%s'  ACTUAL -> %s\n", i,
               posClass(i, n), kindOf(e).c_str(),
               std::string(e->VpiName()).c_str(),
               actBrief(actOf(e)).c_str());
        if (auto* bs = any_cast<const bit_select*>(e))
            printf("               |vpiIndex -> %s\n",
                   payloadShort(bs->VpiIndex()).c_str());
        i++;
    }
}

static void bisect(const BaseClass* L, const BaseClass* R) {
    printf("   -- FIELD BISECTION (generated Compare order) --\n");
    printf("      BaseClass VpiType   : %d vs %d -> %d\n", (int)L->VpiType(),
           (int)R->VpiType(), (int)L->VpiType() - (int)R->VpiType());
    printf("      BaseClass VpiName   : '%s' vs '%s' -> %d\n",
           std::string(L->VpiName()).c_str(), std::string(R->VpiName()).c_str(),
           std::string(L->VpiName()).compare(std::string(R->VpiName())));
    printf("      BaseClass VpiDefName: '%s' vs '%s' -> %d\n",
           std::string(L->VpiDefName()).c_str(),
           std::string(R->VpiDefName()).c_str(),
           std::string(L->VpiDefName()).compare(std::string(R->VpiDefName())));
    auto* el = any_cast<const expr*>(L);
    auto* er = any_cast<const expr*>(R);
    if (el && er) {
        printf("      expr VpiDecompile   : '%s' vs '%s' -> %d\n",
               std::string(el->VpiDecompile()).c_str(),
               std::string(er->VpiDecompile()).c_str(),
               std::string(el->VpiDecompile())
                   .compare(std::string(er->VpiDecompile())));
        printf("      expr VpiSize        : %d vs %d -> %d\n", el->VpiSize(),
               er->VpiSize(), el->VpiSize() - er->VpiSize());
        printf("      expr Typespec       : %s\n            vs %s\n",
               tsEdge(el).c_str(), tsEdge(er).c_str());
    }
    auto* hl = any_cast<const hier_path*>(L);
    auto* hr = any_cast<const hier_path*>(R);
    if (hl && hr) {
        printf("      hier_path Path_elems: %zu vs %zu\n",
               hl->Path_elems() ? hl->Path_elems()->size() : 0,
               hr->Path_elems() ? hr->Path_elems()->size() : 0);
        elems("        GOLDEN", hl);
        elems("        OURS  ", hr);
        printf("      hier_path Root_value: %s\n            vs %s\n",
               payloadShort(hl->Root_value()).c_str(),
               payloadShort(hr->Root_value()).c_str());
    }
}

static void chain(const char* tag, const BaseClass* o) {
    printf("   -- OWNER CHAIN (%s) --\n", tag);
    const BaseClass* p = o ? o->VpiParent() : nullptr;
    for (int d = 0; d < 8 && p; d++) {
        printf("     %*s|vpiParent -> %s\n", d * 2, "", payload(p).c_str());
        p = p->VpiParent();
    }
}

// ---------------------------------------------------------------------------
// PAIRING.  Every hier_path in a database, keyed on span+name -- the same join
// the census uses.  A key with more than one object keeps them all (multiset).
// ---------------------------------------------------------------------------
struct HP { const hier_path* h; };
// THE JOIN KEY DELIBERATELY DROPS VpiFile: golden's hier_paths carry the
// source path and OURS ARE EMPTY (RESUME.md section 9's own note), and
// `VpiFile` is not a field any generated `Compare` reads.  Keying on it would
// join NOTHING -- measured: 0 of 51 golden keys.
static std::string hpKey(const BaseClass* o) {
    char b[128];
    snprintf(b, sizeof b, "%u:%u-%u:%u", o->VpiLineNo(),
             (unsigned)o->VpiColumnNo(), o->VpiEndLineNo(),
             (unsigned)o->VpiEndColumnNo());
    return std::string(b) + "|" + std::string(o->VpiName());
}
static void collectHP(Serializer& s, std::map<std::string,
                                              std::vector<const hier_path*>>& m) {
    for (const auto& p : s.AllObjects()) {
        const BaseClass* q = p.first;
        if (!q || q->UhdmType() != uhdmhier_path) continue;
        m[hpKey(q)].push_back((const hier_path*)q);
    }
}

int main(int argc, char** argv) {
    if (argc < 4) {
        fprintf(stderr,
                "usage: own115 <head|paths|ladder> <golden> <ours> [arg]\n");
        return 2;
    }
    std::string mode = argv[1];
    Serializer sg, so;
    std::vector<vpiHandle> hg = sg.Restore(std::string(argv[2]));
    std::vector<vpiHandle> ho = so.Restore(std::string(argv[3]));
    if (hg.empty() || ho.empty()) {
        fprintf(stderr, "FATAL: load failed\n");
        return 3;
    }
    const design* dg = (const design*)((const uhdm_handle*)hg[0])->object;
    const design* dd = (const design*)((const uhdm_handle*)ho[0])->object;

    std::map<std::string, std::vector<const hier_path*>> mg, mo;
    collectHP(sg, mg);
    collectHP(so, mo);

    if (mode == "paths") {
        const char* filt = argc > 4 ? argv[4] : nullptr;
        int joined = 0, gonly = 0, oonly = 0, diff = 0;
        printf("== PATHS: golden %zu keys, ours %zu keys\n", mg.size(),
               mo.size());
        for (auto& kv : mg) {
            if (filt && kv.first.find(filt) == std::string::npos) continue;
            auto it = mo.find(kv.first);
            if (it == mo.end()) { gonly++; continue; }
            for (size_t j = 0; j < kv.second.size() && j < it->second.size();
                 j++) {
                const hier_path* G = kv.second[j];
                const hier_path* O = it->second[j];
                joined++;
                // per-element binding signature, both sides
                auto sig = [](const hier_path* h) {
                    std::string s;
                    size_t n = h->Path_elems() ? h->Path_elems()->size() : 0;
                    for (size_t i = 0; i < n; i++) {
                        auto* e = h->Path_elems()->at(i);
                        if (i) s += " ; ";
                        s += std::string(posClass(i, n)) + ":" + kindOf(e) +
                             "->" + actBrief(actOf(e));
                    }
                    return s;
                };
                std::string sgS = sig(G), soS = sig(O);
                if (sgS == soS) continue;
                diff++;
                printf("-- KEY %s\n", kv.first.c_str());
                printf("   scope=%s carrier=%s\n", scopeOf(G).c_str(),
                       carrierOf(G).c_str());
                printf("   G: %s\n", sgS.c_str());
                printf("   O: %s\n", soS.c_str());
                printf("   G rootvalue=%s  ts=%s\n",
                       payloadShort(G->Root_value()).c_str(),
                       tsEdge(G).c_str());
                printf("   O rootvalue=%s  ts=%s\n",
                       payloadShort(O->Root_value()).c_str(),
                       tsEdge(O).c_str());
            }
        }
        for (auto& kv : mo)
            if (!mg.count(kv.first)) oonly++;
        printf("== joined=%d differing=%d golden-only-keys=%d ours-only-keys=%d\n",
               joined, diff, gonly, oonly);
        return 0;
    }

    if (mode == "ladder") {
        // Step 0: the pristine head.
        for (int step = 0; step < 4; step++) {
            CompareContext ctx;
            int r = dg->Compare(dd, &ctx);
            printf("== LADDER STEP %d : design::Compare -> %d\n", step, r);
            const BaseClass* L = ctx.m_failedLhs;
            const BaseClass* R = ctx.m_failedRhs;
            printf("   LHS(golden) = %s  %s\n", payload(L).c_str(),
                   L ? spanOf(L).c_str() : "");
            printf("   RHS(ours)   = %s  %s\n", payload(R).c_str(),
                   R ? spanOf(R).c_str() : "");
            if (r == 0) break;
            int masked = 0;
            if (step == 0) {
                // mask every paired hier_path's Typespec (earl114's field)
                for (auto& kv : mg) {
                    auto it = mo.find(kv.first);
                    if (it == mo.end()) continue;
                    for (size_t j = 0;
                         j < kv.second.size() && j < it->second.size(); j++) {
                        const_cast<hier_path*>(kv.second[j])
                            ->Typespec(const_cast<ref_typespec*>(
                                it->second[j]->Typespec()));
                        masked++;
                    }
                }
                printf("   MASKED %d hier_path Typespec edges (golden:=ours)\n",
                       masked);
            } else if (step == 1) {
                // mask every paired hier_path's per-element Actual_group
                for (auto& kv : mg) {
                    auto it = mo.find(kv.first);
                    if (it == mo.end()) continue;
                    for (size_t j = 0;
                         j < kv.second.size() && j < it->second.size(); j++) {
                        auto* G = kv.second[j];
                        auto* O = it->second[j];
                        auto* ge = G->Path_elems();
                        auto* oe = O->Path_elems();
                        if (!ge || !oe || ge->size() != oe->size()) continue;
                        for (size_t i = 0; i < ge->size(); i++)
                            if (setAct(const_cast<BaseClass*>((const BaseClass*)ge->at(i)),
                                       const_cast<any*>(actOf(oe->at(i)))))
                                masked++;
                    }
                }
                printf("   MASKED %d Path_elems Actual_group edges "
                       "(golden:=ours)\n", masked);
            } else if (step == 2) {
                // mask every paired hier_path's Root_value
                for (auto& kv : mg) {
                    auto it = mo.find(kv.first);
                    if (it == mo.end()) continue;
                    for (size_t j = 0;
                         j < kv.second.size() && j < it->second.size(); j++) {
                        const_cast<hier_path*>(kv.second[j])
                            ->Root_value(const_cast<any*>(
                                it->second[j]->Root_value()));
                        masked++;
                    }
                }
                printf("   MASKED %d Root_value edges (golden:=ours)\n", masked);
            } else {
                break;
            }
        }
        return 0;
    }

    // mode == head
    int maxIt = argc > 4 ? atoi(argv[4]) : 1;
    for (int it = 0; it < maxIt; it++) {
        CompareContext ctx;
        int r = dg->Compare(dd, &ctx);
        printf("== ITERATION %d : design::Compare -> %d\n", it, r);
        if (r == 0) { printf("   EQUAL -- no head.\n"); break; }
        const BaseClass* L = ctx.m_failedLhs;
        const BaseClass* R = ctx.m_failedRhs;
        printf("   HEAD LHS(golden) = %s\n", payload(L).c_str());
        printf("   HEAD RHS(ours)   = %s\n", payload(R).c_str());
        chain("golden", L);
        chain("ours", R);
        // A NULL side names the VALUE; the object the judge walks is the
        // OWNER.  For a Path_elems element the owner chain reaches the
        // hier_path directly; for a typespec_member it does NOT (a
        // typespec_member is parented at its struct_typespec), so the owner is
        // found by SEARCHING the non-null side's database for the hier_path
        // whose Path_elems contains it.
        const BaseClass* nn = L ? L : R;
        Serializer& sn = L ? sg : so;
        const hier_path* ownerN = nullptr;
        size_t ownerIdx = 0;
        if (nn) {
            for (const auto& p : sn.AllObjects()) {
                const BaseClass* q = p.first;
                if (!q || q->UhdmType() != uhdmhier_path) continue;
                auto* h = (const hier_path*)q;
                if (!h->Path_elems()) continue;
                for (size_t i = 0; i < h->Path_elems()->size(); i++) {
                    const BaseClass* e = h->Path_elems()->at(i);
                    if (e == nn || actOf(e) == nn) {
                        ownerN = h; ownerIdx = i; break;
                    }
                }
                if (ownerN) break;
            }
        }
        if (ownerN) {
            printf("   OWNING hier_path (%s side), element index %zu:\n",
                   L ? "golden" : "ours", ownerIdx);
            printf("     %s\n", payload(ownerN).c_str());
            printf("     scope=%s carrier=%s\n", scopeOf(ownerN).c_str(),
                   carrierOf(ownerN).c_str());
            auto& other = L ? mo : mg;
            auto oit = other.find(hpKey(ownerN));
            const hier_path* ownerO =
                (oit != other.end() && !oit->second.empty()) ? oit->second[0]
                                                             : nullptr;
            printf("   PAIRED hier_path (other side): %s\n",
                   ownerO ? payload(ownerO).c_str() : "<not found>");
            if (L) { elems("GOLDEN", ownerN); elems("OURS  ", ownerO); }
            else   { elems("GOLDEN", ownerO); elems("OURS  ", ownerN); }
            chain("owner", ownerN);
        }
        if (!L || !R || L->UhdmType() != R->UhdmType()) {
            printf("   KIND MISMATCH or null side -- stop.\n");
            break;
        }
        bisect(L, R);
        auto* el = any_cast<const expr*>(L);
        auto* er = any_cast<const expr*>(R);
        if (el && er) {
            const_cast<expr*>(el)->VpiSize(er->VpiSize());
            const_cast<expr*>(el)->VpiDecompile(er->VpiDecompile());
            const_cast<expr*>(el)->Typespec(
                const_cast<ref_typespec*>(er->Typespec()));
            printf("   MASKED golden head's VpiDecompile/VpiSize/Typespec.\n");
        } else break;
    }
    return 0;
}
