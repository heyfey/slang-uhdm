// r10svs3repro/svsstmts.cpp — THE STATEMENT-LIST CENSUS, both sides, at OWN
// CHILD DEPTH.
//
// uhdm-cmp's head for this pass is `begin: (work@packet::byte_unpack)`, and
// `begin::Compare` compares exactly two things: BaseClass (VpiType / VpiName /
// VpiDefName) and then `SafeCompare(Stmts())` — a POSITIONAL walk.  So the only
// fields that can fail on that head are the three strings and the Stmts list,
// and the only way to read the list is to print it.  A dump grep cannot do it:
// the dump reprints the same object under every back-edge, so "an object" and "a
// dump occurrence" are different things (this campaign's standing law).  This
// enumerates the list through the vpiStmt relation itself, once per element.
//
// Usage: svsstmts <a.uhdm> <b.uhdm> <class-or-scope-fullname> <method-name>
//        A is ALWAYS golden (Surelog); B is ALWAYS ours.
// Searches AllClasses + AllPackages/AllModules Task_funcs for the method, prints
// its Stmt's statement list on each side with kind + span + a per-index verdict:
//   EQ         both sides Compare equal
//   DIFFER     same class, a FIELD inside disagrees
//   DIFFERKIND the two sides emit an element of a DIFFERENT CLASS
//   ONLY_A / ONLY_B  the lists are different lengths
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <uhdm/vpi_visitor.h>

#include <filesystem>
#include <iostream>
#include <string>
#include <vector>
using namespace UHDM;

static std::string base(std::string_view f) {
    size_t p = f.rfind('/');
    return std::string(p == std::string_view::npos ? f : f.substr(p + 1));
}

static std::string at(const BaseClass* n) {
    if (!n) return "<null>";
    return std::string(UhdmName(n->UhdmType())) + " '" + std::string(n->VpiName()) +
           "' " + base(n->VpiFile()) + ":" + std::to_string(n->VpiLineNo()) + ":" +
           std::to_string(n->VpiColumnNo()) + "-" + std::to_string(n->VpiEndLineNo()) +
           ":" + std::to_string(n->VpiEndColumnNo());
}

static const task_func* findTF(const design* d, const std::string& scope,
                               const std::string& meth) {
    auto scan = [&](const std::vector<class_defn*>* v) -> const task_func* {
        if (!v) return nullptr;
        for (auto* c : *v) {
            if (!scope.empty() && std::string(c->VpiName()) != scope) continue;
            if (!c->Task_funcs()) continue;
            for (auto* t : *c->Task_funcs())
                if (std::string(t->VpiName()) == meth) return t;
        }
        return nullptr;
    };
    if (const task_func* t = scan(d->AllClasses())) return t;
    // classes nested in packages/modules are reachable through the same listing
    // in this corpus, but fall back to a package sweep for arms that declare the
    // method at package scope.
    if (d->AllPackages())
        for (auto* p : *d->AllPackages()) {
            if (!p->Task_funcs()) continue;
            for (auto* t : *p->Task_funcs())
                if (std::string(t->VpiName()) == meth) return t;
            if (p->Class_defns())
                for (auto* c : *p->Class_defns()) {
                    if (!scope.empty() && std::string(c->VpiName()) != scope) continue;
                    if (!c->Task_funcs()) continue;
                    for (auto* t : *c->Task_funcs())
                        if (std::string(t->VpiName()) == meth) return t;
                }
        }
    if (d->AllModules())
        for (auto* m : *d->AllModules()) {
            if (!m->Task_funcs()) continue;
            for (auto* t : *m->Task_funcs())
                if (std::string(t->VpiName()) == meth) return t;
        }
    return nullptr;
}

// The body of a task_func is Stmt(); when it is a `begin` the statements hang off
// its Stmts(), otherwise the body IS the single statement.
static std::vector<const any*> bodyStmts(const task_func* t, const any** beg) {
    std::vector<const any*> out;
    *beg = nullptr;
    const any* s = t ? t->Stmt() : nullptr;
    if (!s) return out;
    if (s->UhdmType() == uhdmbegin || s->UhdmType() == uhdmnamed_begin) {
        *beg = s;
        auto* v = (s->UhdmType() == uhdmbegin) ? ((const begin*)s)->Stmts()
                                              : ((const named_begin*)s)->Stmts();
        if (v)
            for (auto* x : *v) out.push_back((const any*)x);
    } else {
        out.push_back(s);
    }
    return out;
}

int main(int argc, char** argv) {
    if (argc < 5) {
        std::cout << "usage: svsstmts <a.uhdm> <b.uhdm> <class-fullname|-> "
                     "<method>\n";
        return 1;
    }
    std::string scope = argv[3], meth = argv[4];
    if (scope == "-") scope.clear();
    Serializer sa, sb;
    auto ha = sa.Restore(std::filesystem::path(argv[1]));
    auto hb = sb.Restore(std::filesystem::path(argv[2]));
    if (ha.empty() || hb.empty()) { std::cout << "RESTORE FAILED\n"; return 2; }
    const design* da = (const design*)((uhdm_handle*)ha[0])->object;
    const design* db = (const design*)((uhdm_handle*)hb[0])->object;
    const task_func* ta = findTF(da, scope, meth);
    const task_func* tb = findTF(db, scope, meth);
    if (!ta || !tb) {
        std::cout << "METHOD NOT FOUND  A=" << (ta ? "ok" : "null") << " B="
                  << (tb ? "ok" : "null") << "\n";
        return 3;
    }
    std::cout << "A(golden) " << at(ta) << "\n";
    std::cout << "B(ours)   " << at(tb) << "\n";
    const any *ba = nullptr, *bb = nullptr;
    auto va = bodyStmts(ta, &ba);
    auto vb = bodyStmts(tb, &bb);
    std::cout << "A body container " << at((const BaseClass*)ba) << "\n";
    std::cout << "B body container " << at((const BaseClass*)bb) << "\n";
    std::cout << "STMTS golden=" << va.size() << " ours=" << vb.size()
              << (va.size() == vb.size() ? "  (SAME LENGTH)"
                                         : "  *** LENGTH MISMATCH ***")
              << "\n";
    size_t n = va.size() > vb.size() ? va.size() : vb.size();
    int eq = 0, dif = 0, difk = 0, only = 0;
    for (size_t i = 0; i < n; i++) {
        const any* x = i < va.size() ? va[i] : nullptr;
        const any* y = i < vb.size() ? vb[i] : nullptr;
        std::string verdict;
        if (!x) { verdict = "ONLY_B"; only++; }
        else if (!y) { verdict = "ONLY_A"; only++; }
        else if (x->UhdmType() != y->UhdmType()) { verdict = "DIFFERKIND"; difk++; }
        else {
            CompareContext ctx;
            verdict = (x->Compare(y, &ctx) == 0) ? "EQ" : "DIFFER";
            if (verdict == "EQ") eq++; else dif++;
        }
        std::cout << "  [" << i << "] " << verdict << "\n      A " << at((const BaseClass*)x)
                  << "\n      B " << at((const BaseClass*)y) << "\n";
    }
    std::cout << "TOTALS EQ=" << eq << " DIFFER=" << dif << " DIFFERKIND=" << difk
              << " ONLY=" << only << "\n";
    return 0;
}
