// r10uvm160 — THE BAD-OPERAND CENSUS.  Descended from
// r10uvm158repro/ct158cen.cpp (its owner walk, its rootView map, its esc/span/
// kd helpers and its NULL-vs-EMPTY vector convention are re-used verbatim);
// the row types below are the ones THIS head needs and no earlier census
// could see:
//
//   OP    one row per `operation`: its vpiOpType, its span, and the SIZE and
//         ORDERED KIND LIST of its `vpiOperand` vector.  -1 is a NULL vector,
//         0 is a present-but-EMPTY one — the judge's SafeCompare treats those
//         as different answers (RESUME.md §9), and the head of this pass is
//         exactly `operation::Operands` with ours EMPTY and golden's 3.
//   ASGN  one row per `assignment` / `assign_stmt` / `cont_assign`: the KIND
//         of its Rhs (or `<null>`) and of its Lhs, so a whole dropped Rhs is
//         visible next to a truncated operand list.
//   ARG   one row per call object: the SIZE and ordered kind list of its
//         argument vector (a bad ARGUMENT inside a good call).
//   COND  one row per `if_stmt` / `while_stmt` / `do_while` / `case_stmt` /
//         `return_stmt` / `for_stmt`: the kind of the condition expression it
//         carries, or `<null>`.
//   HP    one row per `hier_path`: its name and the ordered kind list of its
//         `vpiActual` path elements.
//
// MEASUREMENT ONLY; the official uhdm-cmp is the judge.  LHS is ALWAYS golden.
//
// build: g++ -O2 -std=c++17 ct160cen.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct160cen
// usage: ct160cen <file.uhdm> [tag]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <iostream>
#include <map>
#include <set>
#include <string>
#include <vector>
using namespace UHDM;

static std::string kd(const any* t) {
    return t ? std::string(UhdmName(t->UhdmType())) : std::string("<null>");
}
static std::string esc(std::string s) {
    for (auto& c : s) if (c == '\t' || c == '\n') c = ' ';
    return s.empty() ? std::string("-") : s;
}
static std::string span(const any* o) {
    if (!o) return "-";
    return std::to_string(o->VpiLineNo()) + ":" + std::to_string(o->VpiColumnNo()) +
           "-" + std::to_string(o->VpiEndLineNo()) + ":" +
           std::to_string(o->VpiEndColumnNo());
}
static std::string fnm(const any* t) {
    if (!t) return "-";
    if (const scope* sc = any_cast<const scope*>(t)) {
        std::string f(sc->VpiFullName());
        if (!f.empty()) return f;
    }
    return std::string(t->VpiName());
}
// one element of an ordered vector listing: KIND(NAME) or KIND
static std::string el(const any* o) {
    if (!o) return "<null>";
    std::string n(o->VpiName());
    if (n.empty()) {
        // a constant has no name; its decompile is what the judge reads
        if (o->UhdmType() == uhdmconstant)
            n = std::string(((const constant*)o)->VpiDecompile());
    }
    return kd(o) + (n.empty() ? std::string("") : ("(" + esc(n) + ")"));
}

int main(int argc, char** argv) {
    if (argc < 2) { std::cerr << "usage: ct160cen <file.uhdm> [tag]\n"; return 2; }
    std::string tag = argc > 2 ? argv[2] : "T";
    Serializer s;
    if (s.Restore(std::string(argv[1])).empty()) {
        std::cout << "RESTORE_FAIL\t" << tag << "\n"; return 3;
    }
    std::map<const any*, std::string> rootView;
    for (auto& kv : s.AllObjects()) {
        const any* o = kv.first;
        if (!o || o->UhdmType() != uhdmdesign) continue;
        const design* d = (const design*)o;
        if (auto* v = d->TopPackages())   for (auto* p : *v) rootView.emplace(p, "ELABPKG");
        if (auto* v = d->TopModules())    for (auto* p : *v) rootView.emplace(p, "TOPMOD");
        if (auto* v = d->AllPackages())   for (auto* p : *v) rootView.emplace(p, "DEFPKG");
        if (auto* v = d->AllModules())    for (auto* p : *v) rootView.emplace(p, "DEFMOD");
        if (auto* v = d->AllClasses())    for (auto* p : *v) rootView.emplace(p, "DEFCLASS");
        if (auto* v = d->AllPrograms())   for (auto* p : *v) rootView.emplace(p, "DEFPROG");
        if (auto* v = d->AllInterfaces()) for (auto* p : *v) rootView.emplace(p, "DEFIFACE");
    }
    auto walk = [&](const any* o, const any** owner, const any** root,
                    const any** cls) {
        const any* p = o->VpiParent();
        int d = 0;
        while (p && d++ < 300) {
            UHDM_OBJECT_TYPE pt = p->UhdmType();
            if (!*owner && (pt == uhdmfunction || pt == uhdmtask)) *owner = p;
            if (!*cls && pt == uhdmclass_defn) *cls = p;
            auto it = rootView.find(p);
            if (it != rootView.end()) { *root = p; break; }
            if (pt == uhdmdesign) break;
            if (!*owner && (pt == uhdmmodule_inst || pt == uhdmpackage)) *owner = p;
            p = p->VpiParent();
        }
    };
    auto head = [&](const any* o, const char* rt) {
        const any* owner = nullptr; const any* root = nullptr; const any* cls = nullptr;
        walk(o, &owner, &root, &cls);
        std::string oob = "-";
        if (owner && (owner->UhdmType() == uhdmfunction || owner->UhdmType() == uhdmtask)) {
            std::string on(owner->VpiName());
            oob = (on.find("::") != std::string::npos) ? "OOB" : "IB";
        }
        std::cout << tag << "\t" << rt << "\t"
                  << (root ? rootView[root] : std::string("OTHER")) << "\t"
                  << oob << "\t"
                  << (cls ? esc(std::string(((const class_defn*)cls)->VpiDefName()))
                          : std::string("-"))
                  << "\t" << esc(fnm(owner)) << "\t" << span(o) << "\t";
    };
    auto vecList = [&](const std::vector<any*>* v) {
        std::string s2;
        if (v)
            for (auto* e : *v) { if (!s2.empty()) s2 += ","; s2 += el(e); }
        return s2.empty() ? std::string("-") : s2;
    };
    auto vsz = [](const void* v, size_t n) { return v ? (long)n : -1L; };

    for (auto& kv : s.AllObjects()) {
        const any* o = kv.first;
        if (!o) continue;
        UHDM_OBJECT_TYPE t = o->UhdmType();
        if (t == uhdmoperation) {
            const operation* op = (const operation*)o;
            auto* ops = op->Operands();
            head(o, "OP");
            std::cout << op->VpiOpType() << "\t" << kd(o->VpiParent()) << "\t"
                      << vsz(ops, ops ? ops->size() : 0) << "\t"
                      << vecList(ops) << "\n";
            continue;
        }
        if (t == uhdmassignment || t == uhdmassign_stmt || t == uhdmcont_assign) {
            const any* lhs = nullptr; const any* rhs = nullptr;
            if (t == uhdmassignment) {
                lhs = ((const assignment*)o)->Lhs(); rhs = ((const assignment*)o)->Rhs();
            } else if (t == uhdmassign_stmt) {
                lhs = ((const assign_stmt*)o)->Lhs(); rhs = ((const assign_stmt*)o)->Rhs();
            } else {
                lhs = ((const cont_assign*)o)->Lhs(); rhs = ((const cont_assign*)o)->Rhs();
            }
            head(o, "ASGN");
            std::cout << kd(o) << "\t" << el(lhs) << "\t" << el(rhs) << "\t"
                      << span(rhs) << "\n";
            continue;
        }
        if (t == uhdmfunc_call || t == uhdmmethod_func_call || t == uhdmtask_call ||
            t == uhdmmethod_task_call || t == uhdmsys_func_call || t == uhdmsys_task_call) {
            const std::vector<any*>* args = nullptr;
            if (const tf_call* c = any_cast<const tf_call*>(o)) args = c->Tf_call_args();
            head(o, "ARG");
            std::cout << kd(o) << "\t" << esc(std::string(o->VpiName())) << "\t"
                      << vsz(args, args ? args->size() : 0) << "\t"
                      << vecList(args) << "\n";
            continue;
        }
        if (t == uhdmhier_path) {
            auto* pe = ((const hier_path*)o)->Path_elems();
            head(o, "HP");
            std::cout << esc(std::string(o->VpiName())) << "\t"
                      << vsz(pe, pe ? pe->size() : 0) << "\t"
                      << vecList(pe) << "\n";
            continue;
        }
        {
            const any* c = nullptr; bool isCond = false;
            if (t == uhdmif_stmt) { c = ((const if_stmt*)o)->VpiCondition(); isCond = true; }
            else if (t == uhdmif_else) { c = ((const if_else*)o)->VpiCondition(); isCond = true; }
            else if (t == uhdmwhile_stmt) { c = ((const while_stmt*)o)->VpiCondition(); isCond = true; }
            else if (t == uhdmdo_while) { c = ((const do_while*)o)->VpiCondition(); isCond = true; }
            else if (t == uhdmcase_stmt) { c = ((const case_stmt*)o)->VpiCondition(); isCond = true; }
            else if (t == uhdmreturn_stmt) { c = ((const return_stmt*)o)->VpiCondition(); isCond = true; }
            if (isCond) {
                head(o, "COND");
                std::cout << kd(o) << "\t" << el(c) << "\t" << span(c) << "\n";
                continue;
            }
        }
    }
    return 0;
}
