// r10uvm172 — THE STATEMENT-CALL CENSUS.  MEASUREMENT ONLY; the official
// ~/git-repos/UHDM/build/bin/uhdm-cmp is the sole judge.  LHS is ALWAYS golden
// (Surelog), RHS is ALWAYS ours.
//
// ONE ROW per STATEMENT-POSITION call object, where "statement position" is
// decided by the RELATION its owner holds it on, not by a hand-written list of
// parent kinds: every object's edges are enumerated with the generated,
// kind-agnostic `GetByVpiType`, and a call reached on `vpiStmt` (104) or
// `vpiElseStmt` (105) is in statement position.  That is the exact slot the
// head sits in (r10uvm172 README §1: owner `begin`, edge vpiType=104).
//
// THE KEY is (line, enclosing-subroutine NAME, ordinal within THIS COPY of the
// body).  The two producers give the SAME statement DIFFERENT spans — golden's
// collapsed `func_call` covers the whole statement, ours covers the method
// token — so a span key would join nothing; and a database holds several
// COPIES of the same body (DEF, elaborated, wildcard-import clones), so the
// ordinal is computed per enclosing subroutine OBJECT and the copies then show
// up as the key's MULTIPLICITY.  The home chain is EVIDENCE, never a key
// (RESUME.md §9: the two producers label the DEF/ELAB/clone copies
// differently).
//
// build: g++ -O2 -std=c++17 ct172cen.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct172cen
// usage: ct172cen <db.uhdm> [--rel|--pred]
//   --rel   prints the relation histogram (how the statement slot was decided)
//   --pred  THE A-PRIORI MOVER SUPERSET, computable from ONE PRISTINE database:
//           every statement-position `method_func_call`/`method_task_call` with
//           a vpiPrefix whose prefix NAME is ALSO the name of some `function`
//           or `task` object in the SAME database.  Our predicate needs slang
//           scope knowledge this tool does not have, so this is deliberately a
//           SUPERSET (it ignores which scope the subroutine lives in): a row
//           that prints nothing here CANNOT move, which is the direction a
//           mover prediction has to be safe in.
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <algorithm>
#include <cstdio>
#include <cstring>
#include <map>
#include <string>
#include <vector>

using namespace UHDM;

static std::string kn(const BaseClass* o) {
    return o ? std::string(UhdmName(o->UhdmType())) : std::string("<null>");
}
static std::string nm(const BaseClass* o) {
    return o ? std::string(o->VpiName()) : std::string("<null>");
}
static bool isCall(const BaseClass* o) {
    const UHDM_OBJECT_TYPE t = o->UhdmType();
    return t == uhdmfunc_call || t == uhdmtask_call ||
           t == uhdmmethod_func_call || t == uhdmmethod_task_call;
}
static const BaseClass* encSub(const BaseClass* o) {
    for (const BaseClass* p = o->VpiParent(); p; p = p->VpiParent())
        if (p->UhdmType() == uhdmfunction || p->UhdmType() == uhdmtask) return p;
    return nullptr;
}
static std::string homeChain(const BaseClass* o) {
    std::string s;
    for (const BaseClass* p = o->VpiParent(); p; p = p->VpiParent()) {
        const UHDM_OBJECT_TYPE t = p->UhdmType();
        if (t != uhdmpackage && t != uhdmclass_defn && t != uhdmmodule_inst &&
            t != uhdmfunction && t != uhdmtask)
            continue;
        s += "<" + kn(p) + ":" + nm(p);
    }
    return s;
}

int main(int argc, char** argv) {
    if (argc < 2) { fprintf(stderr, "usage: ct172cen <db.uhdm> [--rel]\n"); return 2; }
    const bool relHist = (argc > 2 && strcmp(argv[2], "--rel") == 0);
    const bool predMode = (argc > 2 && strcmp(argv[2], "--pred") == 0);
    Serializer s;
    if (s.Restore(std::string(argv[1])).empty()) { printf("RESTORE_FAIL\n"); return 3; }

    // PASS 1 — which relation holds each call object.
    // A call can be reached on MORE THAN ONE relation (the same object is a
    // `begin`'s vpiStmt and, in some shapes, another owner's operand), so this
    // records the SET of relations, never a last-writer int: a last-writer map
    // silently dropped ten of arm E's eighteen statement calls in the first
    // cut of this instrument.
    std::map<const BaseClass*, std::vector<int>> relOf;
    std::map<int, int> hist;
    for (auto& kv : s.AllObjects()) {
        const BaseClass* X = kv.first;
        if (!X) continue;
        for (int t = 1; t <= 2100; ++t) {
            auto tup = X->GetByVpiType(t);
            const BaseClass* one = std::get<0>(tup);
            const std::vector<const BaseClass*>* vec = std::get<2>(tup);
            if (one && isCall(one)) { relOf[one].push_back(t); hist[t]++; }
            if (vec)
                for (const BaseClass* e : *vec)
                    if (e && isCall(e)) { relOf[e].push_back(t); hist[t]++; }
        }
    }
    if (relHist) {
        for (auto& kv : hist) printf("REL %d n=%d\n", kv.first, kv.second);
        return 0;
    }

    if (predMode) {
        std::map<std::string, int> subNames;
        for (auto& kv : s.AllObjects()) {
            const BaseClass* o = kv.first;
            if (!o) continue;
            const UHDM_OBJECT_TYPE t = o->UhdmType();
            if (t == uhdmfunction || t == uhdmtask) subNames[nm(o)]++;
        }
        std::vector<std::string> pr;
        for (auto& kv : relOf) {
            const BaseClass* o = kv.first;
            bool stmtPos = false;
            for (int t : kv.second)
                if (t == vpiStmt || t == vpiElseStmt) stmtPos = true;
            if (!stmtPos) continue;
            const BaseClass* px = nullptr;
            if (o->UhdmType() == uhdmmethod_func_call)
                px = any_cast<const method_func_call*>(o)->Prefix();
            else if (o->UhdmType() == uhdmmethod_task_call)
                px = any_cast<const method_task_call*>(o)->Prefix();
            if (!px) continue;
            const std::string pn = nm(px);
            if (!subNames.count(pn)) continue;
            char b[900];
            snprintf(b, sizeof b, "PRED L%u:%u pfx=%s call=%s sub=%s",
                     (unsigned)o->VpiLineNo(), (unsigned)o->VpiColumnNo(),
                     pn.c_str(), nm(o).c_str(),
                     encSub(o) ? nm(encSub(o)).c_str() : "-");
            pr.push_back(b);
        }
        std::sort(pr.begin(), pr.end());
        pr.erase(std::unique(pr.begin(), pr.end()), pr.end());
        for (const std::string& r : pr) printf("%s\n", r.c_str());
        printf("-- PRED cells=%zu\n", pr.size());
        return 0;
    }

    // PASS 2 — the statement-position calls, grouped by enclosing subroutine
    // OBJECT so the ordinal is per COPY of the body.
    struct Row { unsigned line, col; std::string payload; };
    std::map<const BaseClass*, std::vector<Row>> byCopy;
    for (auto& kv : relOf) {
        const BaseClass* o = kv.first;
        bool stmtPos = false;
        for (int t : kv.second)
            if (t == vpiStmt || t == vpiElseStmt) stmtPos = true;
        if (!stmtPos) continue;
        const UHDM_OBJECT_TYPE t = o->UhdmType();
        std::string link = "-", pfx = "-";
        int nargs = -1;
        if (t == uhdmfunc_call) {
            const func_call* f = any_cast<const func_call*>(o);
            link = f->Function() ? ("F:" + nm(f->Function())) : "F:0";
            if (f->Tf_call_args()) nargs = (int)f->Tf_call_args()->size();
        } else if (t == uhdmtask_call) {
            const task_call* f = any_cast<const task_call*>(o);
            link = f->Task() ? ("T:" + nm(f->Task())) : "T:0";
            if (f->Tf_call_args()) nargs = (int)f->Tf_call_args()->size();
        } else if (t == uhdmmethod_func_call) {
            const method_func_call* f = any_cast<const method_func_call*>(o);
            link = f->Function() ? ("F:" + nm(f->Function())) : "F:0";
            pfx = f->Prefix() ? nm(f->Prefix()) : "-";
            if (f->Tf_call_args()) nargs = (int)f->Tf_call_args()->size();
        } else {
            const method_task_call* f = any_cast<const method_task_call*>(o);
            link = f->Task() ? ("T:" + nm(f->Task())) : "T:0";
            pfx = f->Prefix() ? nm(f->Prefix()) : "-";
            if (f->Tf_call_args()) nargs = (int)f->Tf_call_args()->size();
        }
        const BaseClass* sub = encSub(o);
        char b[1400];
        snprintf(b, sizeof b, "kind=%s name=%s link=%s pfx=%s args=%d",
                 kn(o).c_str(), nm(o).c_str(), link.c_str(), pfx.c_str(), nargs);
        byCopy[sub].push_back({(unsigned)o->VpiLineNo(),
                               (unsigned)o->VpiColumnNo(), std::string(b)});
    }
    std::vector<std::string> out;
    for (auto& kv : byCopy) {
        std::vector<Row>& v = kv.second;
        std::sort(v.begin(), v.end(), [](const Row& a, const Row& b) {
            return a.line != b.line ? a.line < b.line : a.col < b.col;
        });
        // The ordinal runs within ONE LINE of ONE COPY, so an unrelated
        // statement appearing on another line can never shift a key.
        unsigned prevLine = 0; int ord = 0;
        for (Row& r : v) {
            if (r.line != prevLine) { prevLine = r.line; ord = 0; } else ++ord;
            char b[1700];
            snprintf(b, sizeof b, "L%u#%d sub=%s %s home=%s", r.line, ord,
                     kv.first ? nm(kv.first).c_str() : "-", r.payload.c_str(),
                     kv.first ? homeChain(kv.first).c_str() : "-");
            out.push_back(b);
        }
    }
    std::sort(out.begin(), out.end());
    for (const std::string& r : out) printf("%s\n", r.c_str());
    return 0;
}
