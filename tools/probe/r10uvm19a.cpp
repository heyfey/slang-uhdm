// r10uvm15c: r10uvm7b + WHY.  A `constant vs constant` (or any expr-vs-expr)
// row says nothing about which cmp-compared property failed: expr::Compare
// walks VpiDecompile, VpiSize, Typespec and constant::Compare adds
// VpiConstType — locations are NOT compared, so the dump-diff proxy cannot
// tell an anchoring difference from a value difference.  mode=why prints, per
// differing pair, the properties themselves; mode=whycls histograms the
// FIRST property that differs.
//
// r10uvm7b: BODY-LEVEL differ for task_func objects.  The cut-instance
// localizer (r10fsv3d) reports ONE first-fail per Task_funcs entry, so a
// package whose 787 of 894 bodies differ collapses to 787 unrelated-looking
// rows.  This splits each body into its PARTS (Io_decls, Return, Variables,
// Scopes, Stmt drilled through begin/named_begin) and cut-seeds every
// package/design/module so Instance() recursion is a no-op — the pair printed
// is then LOCAL to the part.
//   r10uvm7b <golden.uhdm> <ours.uhdm> [mode]
//     mode=rows (default)  one line per differing part
//     mode=part            histogram by part name
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <map>
#include <string>
#include <vector>
#include <algorithm>
using namespace UHDM;

static std::vector<const BaseClass*> g_cut;
static std::map<std::string, int> g_part;
static bool g_rows = true;
static bool g_why = false;    // print per-pair property detail
static bool g_whycls = false; // histogram the FIRST differing property
// r10uvm19 additions: mode=tree prints, per failing pair, the WHOLE expression
// on both sides (operands recursively, each ref's vpiActual and each expr's
// typespec) plus the VpiParent CHAIN of the golden side — a `constant vs
// operation` row says only that one side folded; the tree says WHICH
// expression and in which syntactic position.  g_filter (argv[5]) keeps only
// pairs whose "<Lkind> vs <Rkind>" matches.
static bool g_tree = false;
static std::string g_filter;

static std::string d1(const BaseClass* o) {
    if (!o) return "<null>";
    return std::string(UhdmName(o->UhdmType())) + " '" +
           std::string(o->VpiName()) + "' " + std::to_string(o->VpiLineNo()) +
           ":" + std::to_string(o->VpiColumnNo());
}

// The cmp-compared properties of an expr, in expr::Compare / constant::Compare
// order.  Anything not listed here (line, column, file, parent, fullname) is
// invisible to uhdm-cmp.
static std::string tsKind(const expr* e) {
    auto* rt = e->Typespec();
    if (!rt) return "<none>";
    auto* at = rt->Actual_typespec();
    if (!at) return "ref<null>";
    return std::string(UhdmName(at->UhdmType())) + "'" +
           std::string(at->VpiName()) + "'";
}

static std::string exprDesc(const BaseClass* o) {
    if (!o) return "<null>";
    auto* e = dynamic_cast<const expr*>(o);
    if (!e) return d1(o);
    std::string s = std::string(UhdmName(o->UhdmType())) + " dec='" +
                    std::string(e->VpiDecompile()) + "' sz=" +
                    std::to_string(e->VpiSize()) + " ts=" + tsKind(e);
    if (o->UhdmType() == uhdmconstant)
        s += " ct=" + std::to_string(((const constant*)o)->VpiConstType());
    return s;
}

// Which property fails FIRST, in the order uhdm-cmp itself walks.
static std::string firstDiff(const BaseClass* a, const BaseClass* b) {
    if (!a || !b) return "presence";
    if (a->UhdmType() != b->UhdmType()) return "VpiType";
    if (a->VpiName() != b->VpiName()) return "VpiName";
    auto* ea = dynamic_cast<const expr*>(a);
    auto* eb = dynamic_cast<const expr*>(b);
    if (!ea || !eb) return "other";
    if (ea->VpiDecompile() != eb->VpiDecompile()) return "VpiDecompile";
    if (ea->VpiSize() != eb->VpiSize()) return "VpiSize";
    if (a->UhdmType() == uhdmconstant &&
        ((const constant*)a)->VpiConstType() !=
            ((const constant*)b)->VpiConstType())
        return "VpiConstType";
    if (tsKind(ea) != tsKind(eb)) return "Typespec";
    return "deeper";
}

// Whole expression, operand by operand, with each ref's vpiActual and each
// expr's resolved typespec — the projection the cmp actually walks.
static std::string exprTree(const any* e, int d = 0) {
    if (!e) return "<null>";
    std::string r = std::string(UhdmName(e->UhdmType()));
    if (!e->VpiName().empty()) r += " '" + std::string(e->VpiName()) + "'";
    if (auto* ex = any_cast<const expr*>(e)) {
        if (!ex->VpiDecompile().empty())
            r += " dec='" + std::string(ex->VpiDecompile()) + "'";
        r += " sz=" + std::to_string(ex->VpiSize());
        r += " ts=" + tsKind(ex);
    }
    if (e->UhdmType() == uhdmconstant)
        r += " ct=" + std::to_string(((const constant*)e)->VpiConstType());
    if (e->UhdmType() == uhdmref_obj) {
        auto* a = ((const ref_obj*)e)->Actual_group();
        r += " ->" + (a ? std::string(UhdmName(a->UhdmType())) + " '" +
                              std::string(a->VpiName()) + "'@" +
                              std::to_string(a->VpiLineNo()) + ":" +
                              std::to_string(a->VpiColumnNo())
                        : std::string("<null>"));
    }
    if (d < 5)
        if (auto* op = any_cast<const operation*>(e))
            if (auto* os = op->Operands()) {
                r += " op" + std::to_string(op->VpiOpType()) + "(";
                for (size_t i = 0; i < os->size(); i++)
                    r += (i ? ", " : "") + exprTree((*os)[i], d + 1);
                r += ")";
            }
    return r;
}

// Where in the tree the failing object sits: the kinds of its ancestors, with
// each one's line:col, up to the enclosing body.
static std::string parentChain(const BaseClass* o) {
    std::string r;
    int guard = 0;
    for (const BaseClass* p = o ? o->VpiParent() : nullptr; p && guard++ < 12;
         p = p->VpiParent()) {
        r += " < " + std::string(UhdmName(p->UhdmType()));
        if (!p->VpiName().empty()) r += " '" + std::string(p->VpiName()) + "'";
        r += "@" + std::to_string(p->VpiLineNo()) + ":" +
             std::to_string(p->VpiColumnNo());
        auto k = p->UhdmType();
        if (k == uhdmfunction || k == uhdmtask || k == uhdmclass_defn ||
            k == uhdmpackage || k == uhdmmodule_inst)
            break;
    }
    return r;
}

static void note(const std::string& tag, const std::string& part,
                 const BaseClass* fa, const BaseClass* fb) {
    std::string ka = fa ? std::string(UhdmName(fa->UhdmType())) : "<null>";
    std::string kb = fb ? std::string(UhdmName(fb->UhdmType())) : "<null>";
    if (g_tree) {
        std::string key = ka + " vs " + kb;
        if (g_filter.empty() || key == g_filter) {
            std::cout << tag << " [" << part << "] " << key << "\n"
                      << "    L " << exprTree(fa) << "\n"
                      << "      Lp" << parentChain(fa) << "\n"
                      << "    R " << exprTree(fb) << "\n"
                      << "      Rp" << parentChain(fb) << "\n";
        }
        g_part[part + " | " + key]++;
        return;
    }
    if (g_whycls)
        g_part[part + " | " + ka + " vs " + kb + " | " + firstDiff(fa, fb)]++;
    else
        g_part[part + " | " + ka + " vs " + kb]++;
    if (g_why)
        std::cout << tag << " [" << part << "] why=" << firstDiff(fa, fb)
                  << "\n    L " << d1(fa) << "  " << exprDesc(fa) << "\n    R "
                  << d1(fb) << "  " << exprDesc(fb) << "\n";
    else if (g_rows)
        std::cout << tag << " [" << part << "]\n    L " << d1(fa) << "\n    R "
                  << d1(fb) << "\n";
}

static bool cmp1(const std::string& tag, const std::string& part,
                 const BaseClass* a, const BaseClass* b) {
    if (!a && !b) return true;
    if (!a || !b) {
        note(tag, part, a, b);
        return false;
    }
    CompareContext ctx;
    for (auto* c : g_cut) ctx.m_visited.insert(c);
    if (a->Compare(b, &ctx) == 0) return true;
    // Compare returns nonzero without setting the failed pair when the
    // mismatch is a SCALAR PROPERTY of the compared object itself; name the
    // object then, not <null> vs <null>.
    if (!ctx.m_failedLhs && !ctx.m_failedRhs)
        note(tag, part + "/self", a, b);
    else
        note(tag, part, ctx.m_failedLhs, ctx.m_failedRhs);
    return false;
}

template <typename V>
static void cmpVec(const std::string& tag, const std::string& part,
                   const V* a, const V* b) {
    size_t na = a ? a->size() : 0, nb = b ? b->size() : 0;
    if (na != nb) {
        g_part[part + " | SIZE"]++;
        if (g_rows)
            std::cout << tag << " [" << part << "] SIZE " << na << " vs " << nb
                      << "\n";
        return;
    }
    for (size_t i = 0; i < na; i++)
        cmp1(tag + "." + part + "[" + std::to_string(i) + "]", part, (*a)[i],
             (*b)[i]);
}

// Drill a statement tree: a `begin` compares its whole Stmts vector, so one
// differing statement deep inside names the outermost block.  Recurse through
// the block kinds so the pair printed is the statement itself.
static void drillStmt(const std::string& tag, const any* a, const any* b,
                      int depth) {
    if (!a && !b) return;  // a body with no statement on either side
    if (!a || !b) {
        note(tag, "Stmt", a, b);
        return;
    }
    if (a->UhdmType() != b->UhdmType()) {
        note(tag, "Stmt", a, b);
        return;
    }
    if (depth < 6 &&
        (a->UhdmType() == uhdmbegin || a->UhdmType() == uhdmnamed_begin)) {
        const VectorOfany *sa = nullptr, *sb = nullptr;
        const VectorOfvariables *va = nullptr, *vb = nullptr;
        if (a->UhdmType() == uhdmbegin) {
            sa = ((const begin*)a)->Stmts();
            sb = ((const begin*)b)->Stmts();
        } else {
            sa = ((const named_begin*)a)->Stmts();
            sb = ((const named_begin*)b)->Stmts();
            va = ((const named_begin*)a)->Variables();
            vb = ((const named_begin*)b)->Variables();
        }
        if (va || vb) cmpVec(tag, "BlkVars", va, vb);
        size_t na = sa ? sa->size() : 0, nb = sb ? sb->size() : 0;
        if (na != nb) {
            g_part["Stmts | SIZE"]++;
            if (g_rows)
                std::cout << tag << " [Stmts] SIZE " << na << " vs " << nb
                          << "\n";
            return;
        }
        for (size_t i = 0; i < na; i++)
            drillStmt(tag + "/" + std::to_string(i), (*sa)[i], (*sb)[i],
                      depth + 1);
        return;
    }
    cmp1(tag, "Stmt", a, b);
}

static void doTf(const std::string& tag, const task_func* a,
                 const task_func* b) {
    if (a->UhdmType() != b->UhdmType()) {
        note(tag, "Kind", a, b);
        return;
    }
    cmpVec(tag, "Io_decls", a->Io_decls(), b->Io_decls());
    cmpVec(tag, "Variables", a->Variables(), b->Variables());
    cmpVec(tag, "Parameters", a->Parameters(), b->Parameters());
    cmpVec(tag, "Param_assigns", a->Param_assigns(), b->Param_assigns());
    cmpVec(tag, "Typespecs", a->Typespecs(), b->Typespecs());
    cmpVec(tag, "Scopes", a->Scopes(), b->Scopes());
    if (a->UhdmType() == uhdmfunction)
        cmp1(tag + ".Return", "Return", ((const function*)a)->Return(),
             ((const function*)b)->Return());
    drillStmt(tag + ".Stmt", a->Stmt(), b->Stmt(), 0);
}

static void doTfVec(const std::string& tag, const VectorOftask_func* a,
                    const VectorOftask_func* b) {
    size_t na = a ? a->size() : 0, nb = b ? b->size() : 0;
    if (na != nb) {
        g_part["Task_funcs | SIZE"]++;
        if (g_rows)
            std::cout << tag << " [Task_funcs] SIZE " << na << " vs " << nb
                      << "\n";
        return;
    }
    for (size_t i = 0; i < na; i++)
        doTf(tag + "/" + std::string((*a)[i]->VpiName()), (*a)[i], (*b)[i]);
}

static void doScope(const std::string& tag, const instance* a,
                    const instance* b) {
    doTfVec(tag, a->Task_funcs(), b->Task_funcs());
    auto* ca = a->Class_defns();
    auto* cb = b->Class_defns();
    size_t na = ca ? ca->size() : 0, nb = cb ? cb->size() : 0;
    if (na != nb) {
        g_part["Class_defns | SIZE"]++;
        if (g_rows)
            std::cout << tag << " [Class_defns] SIZE " << na << " vs " << nb
                      << "\n";
        return;
    }
    for (size_t i = 0; i < na; i++)
        doTfVec(tag + "::" + std::string((*ca)[i]->VpiName()),
                (*ca)[i]->Task_funcs(), (*cb)[i]->Task_funcs());
}

int main(int argc, char** argv) {
    Serializer sa, sb;
    auto ha = sa.Restore(std::filesystem::path(argv[1]));
    auto hb = sb.Restore(std::filesystem::path(argv[2]));
    const design* da = (const design*)((uhdm_handle*)ha[0])->object;
    const design* db = (const design*)((uhdm_handle*)hb[0])->object;
    std::string mode = argc > 3 ? argv[3] : "rows";
    g_rows = mode == "rows";
    g_why = mode == "why";
    g_whycls = mode == "whycls";
    g_tree = mode == "tree";
    if (argc > 5) g_filter = argv[5];
    g_cut.push_back(da);
    auto cut = [&](auto* v) {
        if (v)
            for (auto* e : *v) g_cut.push_back(e);
    };
    // Cut EVERY container whose Compare recurses into a whole other body:
    // class_typespec chases Class_defn, a call chases its Function/Task.  With
    // only packages cut, an io_decl of type `uvm_object` reported failures
    // that live inside uvm_object's methods — every row collapsed onto the
    // same handful of shared class bodies.
    auto cutAll = [&](Serializer& s) {
        for (auto& kv : s.AllObjects()) {
            auto* o = (const BaseClass*)kv.first;
            if (!o) continue;
            switch (o->UhdmType()) {
                case uhdmdesign:
                case uhdmpackage:
                case uhdmmodule_inst:
                case uhdminterface_inst:
                case uhdmprogram:
                case uhdmclass_defn:
                case uhdmfunction:
                case uhdmtask:
                    g_cut.push_back(o);
                    break;
                default:
                    break;
            }
        }
    };
    cutAll(sa);
    cutAll(sb);
    auto run = [&](const char* lbl, auto* pa, auto* pb) {
        if (!pa || !pb || pa->size() != pb->size()) {
            std::cout << lbl << ": LIST SIZE MISMATCH\n";
            return;
        }
        for (size_t i = 0; i < pa->size(); i++)
            doScope(std::string(lbl) + "[" + std::string((*pa)[i]->VpiName()) +
                        "]",
                    (*pa)[i], (*pb)[i]);
    };
    std::string only = argc > 4 ? argv[4] : "";
    auto want = [&](const char* l) { return only.empty() || only == l; };
    if (want("DEFPKG")) run("DEFPKG", da->AllPackages(), db->AllPackages());
    if (want("ELABPKG")) run("ELABPKG", da->TopPackages(), db->TopPackages());
    if (want("DEFMOD")) run("DEFMOD", da->AllModules(), db->AllModules());
    if (want("ELABMOD")) run("ELABMOD", da->TopModules(), db->TopModules());
    if (!g_rows && !g_why && !g_tree) {
        std::vector<std::pair<int, std::string>> v;
        for (auto& kv : g_part) v.push_back({kv.second, kv.first});
        std::sort(v.rbegin(), v.rend());
        for (auto& p : v) std::cout << p.first << "  " << p.second << "\n";
    }
    return 0;
}
