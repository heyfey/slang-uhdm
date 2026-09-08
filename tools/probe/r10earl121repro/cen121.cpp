// r10earl121 — THE CENSUS of § `genCaPatKeepTagDefView121`'s cell:
// EVERY OPERAND of EVERY `vpiAssignmentPatternOp` / `vpiMultiAssignmentPatternOp`
// operation in a database, scored on whether it is WRAPPED in a
// `tagged_pattern` or emitted BARE, keyed by the pattern SITE and the
// operand's own span.
//
// MEASUREMENT ONLY.  `uhdm-cmp` is the sole acceptance judge.
//
// THE CELL.  `CompileHelper::compileAssignmentPattern`
// (Surelog CompileExpression.cpp:3671-3838) wraps EVERY keyed pattern item in
// a `tagged_pattern` whose `Typespec()->Actual_typespec()` is a
// `string_typespec` named after the key (a bare member name has no
// `Constant_primary`, so the `slStringConst` arm at :3800 fires).  The tags
// are removed later, by `UHDM::ExprEval::recursiveFlattening`
// (UHDM/build/generated/src/ExprEval.cpp:652-745), which UNWRAPS a tag whose
// typespec is `int_typespec` / `integer_typespec` / `string_typespec` and
// KEEPS every other one — and `recursiveFlattening` only runs from
// `flattenPatternAssignments`, which only runs where a caller hands it the
// target typespec.
//
// KEY (compare-visible only, RESUME.md section 9): our objects can carry an
// EMPTY `VpiFile`, so the FILE IS NOT IN THE KEY.  The key is
//     <home instance fullname> | <pattern op span> | <operand index> | <operand span>
// PAYLOAD: `TP|<tag typespec kind>|<tag name>|<tag span>|<pattern kind>` for a
// wrapped operand, `RAW|<kind>` for a bare one.
//
// A `SITE` row per pattern operation carries the FORM axes the grid is keyed
// on and which `predict121.py` reads: the nearest non-operation ancestor kind
// (the STATEMENT that owns the pattern), whether a `gen_scope` encloses it,
// whether the pattern is NESTED inside another pattern, the operand count, the
// tagged count, and the op's own typespec kind.
//
// build: g++ -O2 -std=c++17 cen121.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o cen121
// usage: cen121 <db.uhdm>
#include <uhdm/uhdm.h>
#include <uhdm/UhdmListener.h>
#include <uhdm/vpi_uhdm.h>

#include <cstdio>
#include <set>
#include <string>
#include <vector>

using namespace UHDM;

static std::string kindOf(const BaseClass* o) {
    return o ? std::string(UhdmName(o->UhdmType())) : std::string("<null>");
}
static std::string span(const BaseClass* o) {
    if (!o) return "<null>";
    char b[96];
    snprintf(b, sizeof b, "%u:%u-%u:%u", o->VpiLineNo(), (unsigned)o->VpiColumnNo(),
             o->VpiEndLineNo(), (unsigned)o->VpiEndColumnNo());
    return b;
}
// The nearest enclosing instance-ish owner, named by VpiFullName when it has
// one.  Same shape as r10earl120's homeOf so the two censuses are readable
// side by side.
static std::string homeOf(const BaseClass* o) {
    for (const BaseClass* p = o; p; p = p->VpiParent()) {
        const std::string k = kindOf(p);
        if (k == "module_inst" || k == "interface_inst" || k == "package" ||
            k == "program" || k == "class_defn" || k == "gen_scope") {
            std::string fn;
            if (const scope* sc = any_cast<const scope*>((const any*)p))
                fn = std::string(sc->VpiFullName());
            if (fn.empty()) fn = std::string(p->VpiName());
            if (fn.empty()) fn = span(p);
            return k + ":" + fn;
        }
    }
    return "<nohome>";
}
static std::string tsKind(const ref_typespec* rt) {
    if (!rt) return "<nots>";
    const typespec* t = rt->Actual_typespec();
    return t ? kindOf(t) : "<null-actual>";
}
static std::string tsName(const ref_typespec* rt) {
    if (!rt) return "";
    const typespec* t = rt->Actual_typespec();
    return t ? std::string(t->VpiName()) : std::string();
}

int main(int argc, char** argv) {
    if (argc < 2) {
        fprintf(stderr, "usage: cen121 <db.uhdm>\n");
        return 2;
    }
    Serializer s;
    const std::vector<vpiHandle> restored = s.Restore(std::string(argv[1]));
    if (restored.empty()) {
        printf("CENRC\t2\tRESTORE-EMPTY\n");
        return 2;
    }
    // REACHABILITY.  `Serializer::AllObjects` also holds objects no relation
    // reaches — our emitter leaves a superseded pattern operation behind at a
    // re-emitted site, and RESUME.md section 9 records that the
    // weaklyReferenced tail is unreachable to the judge.  A census that counts
    // them manufactures phantoms, so every row is stamped `live=1/0` from
    // `UhdmListener`'s own visited set (the walk uhdm-cmp's Compare follows).
    UhdmListener lis;
    for (vpiHandle h : restored) {
        const any* o = (const any*)((const uhdm_handle*)h)->object;
        if (o && o->UhdmType() == uhdmdesign) lis.listenDesign((const design*)o);
    }
    std::set<const BaseClass*> live;
    for (const any* a : lis.getVisited()) live.insert((const BaseClass*)a);

    long nsite = 0, ncell = 0, norph = 0;
    for (const auto& it : s.AllObjects()) {
        const BaseClass* o = it.first;
        if (!o || o->UhdmType() != uhdmoperation) continue;
        const operation* op = (const operation*)o;
        const int ot = op->VpiOpType();
        if (ot != vpiAssignmentPatternOp && ot != vpiMultiAssignmentPatternOp)
            continue;
        const VectorOfany* ops = op->Operands();
        if (!ops) continue;

        // --- the FORM axes ---
        // nearest non-operation ancestor: the statement that owns the pattern.
        std::string owner = "<noowner>";
        bool inGen = false, nested = false;
        {
            const BaseClass* p = op->VpiParent();
            bool first = true;
            for (const BaseClass* q = p; q; q = q->VpiParent()) {
                const std::string k = kindOf(q);
                if (k == "gen_scope" || k == "gen_scope_array") inGen = true;
                if (first && k == "operation") {
                    const operation* pq = (const operation*)q;
                    if (pq->VpiOpType() == vpiAssignmentPatternOp ||
                        pq->VpiOpType() == vpiMultiAssignmentPatternOp)
                        nested = true;
                }
                if (owner == "<noowner>" && k != "operation" &&
                    k != "tagged_pattern")
                    owner = k;
                first = false;
            }
        }
        long ntag = 0;
        for (const any* a : *ops)
            if (a && a->UhdmType() == uhdmtagged_pattern) ntag++;

        const std::string home = homeOf(op);
        const std::string osp = span(op);
        // The TOP-MOST ancestor: tells the DEF listing (`uhdmallModules`) from
        // the ELABORATED tree (`uhdmtopModules`) without reading the dump, and
        // tells an ORPHANED object (parent chain ending nowhere) from a live
        // one.  RESUME.md section 9: the weaklyReferenced tail is unreachable
        // to the judge, so a census that does not separate it manufactures
        // phantoms.
        std::string root = "<self>";
        {
            const BaseClass* q = op;
            while (q->VpiParent()) q = q->VpiParent();
            std::string fn;
            if (const scope* sc = any_cast<const scope*>((const any*)q))
                fn = std::string(sc->VpiFullName());
            if (fn.empty()) fn = std::string(q->VpiName());
            root = kindOf(q) + ":" + fn;
        }
        // BOUND.  `UhdmListener` reaches an object through ANY relation, and
        // our emitter can leave a SUPERSEDED pattern operation parented at the
        // same statement as the live one (two ops per site, both "reachable").
        // The judge only ever reads the one its parent's own compared relation
        // NAMES, so a second discriminator is needed: does the parent's own
        // field point back at this operation?
        int bound = -1;  // -1: parent kind not modelled here
        if (const BaseClass* p = op->VpiParent()) {
            switch (p->UhdmType()) {
                case uhdmcont_assign:
                    bound = (((const cont_assign*)p)->Rhs() == (const expr*)op);
                    break;
                case uhdmparam_assign:
                    bound = (((const param_assign*)p)->Rhs() == (const any*)op);
                    break;
                case uhdmassignment:
                    bound = (((const assignment*)p)->Rhs() == (const any*)op);
                    break;
                case uhdmtagged_pattern:
                    bound = (((const tagged_pattern*)p)->Pattern() ==
                             (const any*)op);
                    break;
                case uhdmoperation: {
                    // A NESTED pattern's `VpiParent` is the OUTER OPERATION on
                    // both sides (Surelog's `compileAssignmentPattern` passes
                    // the operation as `pexpr` and never re-parents the value
                    // it hangs off the `tagged_pattern`), so a nested pattern
                    // is reached EITHER directly, when the outer list is flat,
                    // OR through a `tagged_pattern` when the outer list is
                    // tagged.  Both are BOUND: the judge walks the outer
                    // `Operands` and follows `tagged_pattern::Pattern`.
                    // Counting only the direct form made a nested pattern
                    // "disappear" from our census the moment the outer list
                    // gained its wrappers -- and golden, whose outer list is
                    // tagged, never had it either, so the census manufactured a
                    // phantom on BOTH sides.
                    bound = 0;
                    if (const VectorOfany* po = ((const operation*)p)->Operands())
                        for (const any* a : *po) {
                            if (a == (const any*)op) bound = 1;
                            if (a && a->UhdmType() == uhdmtagged_pattern &&
                                ((const tagged_pattern*)a)->Pattern() ==
                                    (const any*)op)
                                bound = 1;
                        }
                    break;
                }
                case uhdmport:
                    bound = (((const port*)p)->High_conn() == (const any*)op ||
                             ((const port*)p)->Low_conn() == (const any*)op);
                    break;
                default:
                    break;
            }
        }
        const int isLive = (live.count(op) && bound != 0) ? 1 : 0;
        if (!isLive) norph++;
        printf("SITE\t%s|%s\tow=%s\tgen=%d\tnest=%d\tnops=%d\tntag=%ld\tots=%s\troot=%s\tlive=%d\tbound=%d\tid=%u\n",
               home.c_str(), osp.c_str(), owner.c_str(), (int)inGen, (int)nested,
               (int)ops->size(), ntag, tsKind(op->Typespec()).c_str(),
               root.c_str(), isLive, bound, (unsigned)op->UhdmId());
        if (const char* dbg = getenv("R10E121_CHAIN"))
            if (osp.find(dbg) != std::string::npos) {
                fprintf(stderr, "CHAIN op#%u live=%d:", (unsigned)op->UhdmId(),
                        isLive);
                for (const BaseClass* q = op; q; q = q->VpiParent()) {
                    std::string fn;
                    if (const scope* sc = any_cast<const scope*>((const any*)q))
                        fn = std::string(sc->VpiFullName());
                    fprintf(stderr, " <- %s#%u%s%s", kindOf(q).c_str(),
                            (unsigned)q->UhdmId(), fn.empty() ? "" : ":",
                            fn.c_str());
                }
                fprintf(stderr, "\n");
            }
        nsite++;
        if (!isLive) continue;  // an orphan's operands are not the judge's

        // --- the CA row: everything `cont_assign::DeepClone`'s flatten gate
        // (UHDM templates/clone_tree.cpp:803-820) and
        // `ExprEval::flattenPatternAssignments`' own bail-outs read ---
        if (const BaseClass* p = op->VpiParent();
            p && p->UhdmType() == uhdmcont_assign && bound == 1) {
            const cont_assign* ca = (const cont_assign*)p;
            const any* lhs = ca->Lhs();
            std::string lk = kindOf(lhs), ag = "<n/a>", sts = "<none>";
            // `agpar` — the DECLARING scope of the Lhs target, which is the
            // database-visible half of `genCaLhsGenLocal113`: Surelog's
            // `bindVariable` (CompileStmt.cpp:3089-3148) knows function / task /
            // begin / module_inst and NOTHING ELSE, so a target whose declaring
            // scope is a `gen_scope` is NOT found and the writer's own flatten
            // never runs on that assign.  This is what `predict121.py` joins on;
            // the ONE half it cannot see is the namesake test (a gen-local
            // target whose NAME is also declared in an enclosing module body IS
            // found by `bindVariable`), and that can only make the prediction
            // OVER-count, never miss a mover.
            std::string agpar = "<n/a>";
            int nmem = -1, nmemNoTs = -1;
            if (const ref_obj* ro = any_cast<const ref_obj*>(lhs)) {
                ag = kindOf(ro->Actual_group());
                if (const any* agp = ro->Actual_group())
                    agpar = kindOf(agp->VpiParent());
                if (const struct_var* sv =
                        any_cast<const struct_var*>(ro->Actual_group())) {
                    if (const ref_typespec* rt = sv->Typespec())
                        if (const typespec* t = rt->Actual_typespec()) {
                            sts = kindOf(t);
                            if (t->UhdmType() == uhdmstruct_typespec) {
                                const struct_typespec* stp =
                                    (const struct_typespec*)t;
                                nmem = 0;
                                nmemNoTs = 0;
                                if (stp->Members())
                                    for (const typespec_member* m :
                                         *stp->Members()) {
                                        nmem++;
                                        if (!m->Typespec()) nmemNoTs++;
                                    }
                            }
                        }
                }
            }
            printf("CA\t%s|%s\tlhs=%s\tag=%s\tagpar=%s\tlts=%s\tnmem=%d\tnmemnots=%d\tntag=%ld\n",
                   home.c_str(), osp.c_str(), lk.c_str(), ag.c_str(),
                   agpar.c_str(), sts.c_str(), nmem, nmemNoTs, ntag);
        }

        int idx = 0;
        for (const any* a : *ops) {
            std::string key = home + "|" + osp + "|" + std::to_string(idx);
            std::string payload;
            if (a && a->UhdmType() == uhdmtagged_pattern) {
                const tagged_pattern* tp = (const tagged_pattern*)a;
                const any* pat = tp->Pattern();
                key += "|" + span(tp);
                payload = "TP|" + tsKind(tp->Typespec()) + "|" +
                          tsName(tp->Typespec()) + "|" +
                          span(tp->Typespec() ? tp->Typespec()->Actual_typespec()
                                              : nullptr) +
                          "|" + kindOf(pat);
            }
            else {
                key += "|" + span(a);
                payload = "RAW|" + kindOf(a);
            }
            printf("CELL\t%s\t%s\n", key.c_str(), payload.c_str());
            ncell++;
            idx++;
        }
    }
    printf("CENRC\t0\tSITES=%ld\tCELLS=%ld\tORPHANSITES=%ld\n", nsite, ncell,
           norph);
    return 0;
}
