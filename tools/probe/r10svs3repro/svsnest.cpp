// r10svs3repro/svsnest.cpp — THE NESTED statement-tree census.
//
// WHY IT EXISTS: svsstmts.cpp reads a method's TOP-LEVEL body list only, so
// every cell whose drop is written one block level down (a3 p8/p11, a4 q8, and
// the whole a5 arm) shows up there as a single `DIFFER` with no way to tell an
// under-fire from an over-fire from an unrelated field.  This walks the vpiStmt
// tree RECURSIVELY and prints, per side, one indented line per statement with
// its kind and span, so a block's element COUNT is directly readable at every
// depth.
//
// Usage: svsnest <a.uhdm> <b.uhdm> <class-fullname|-> <method>
//        A is ALWAYS golden (Surelog); B is ALWAYS ours.
// Prints the two trees and then, per block, `BLOCK <span> golden=<n> ours=<n>`
// lines pairing blocks up POSITIONALLY by depth-first order — the same order
// SafeCompare walks, so a mismatch here is a mismatch there.
//
// An object is NOT a dump occurrence (standing campaign law): this enumerates
// through the vpiStmt/Stmts relations themselves, once per element, never by
// grepping a dump.
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

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
    return std::string(UhdmName(n->UhdmType())) + " " + base(n->VpiFile()) + ":" +
           std::to_string(n->VpiLineNo()) + ":" + std::to_string(n->VpiColumnNo()) +
           "-" + std::to_string(n->VpiEndLineNo()) + ":" +
           std::to_string(n->VpiEndColumnNo());
}

// Every UHDM class that carries a statement LIST we care about here.  A class
// NOT listed returns no children, which is correct for leaves (assignment,
// $display, ...) and is why the walk terminates.
static bool listOf(const any* s, std::vector<const any*>& out) {
    if (!s) return false;
    const VectorOfany* v = nullptr;
    switch (s->UhdmType()) {
        case uhdmbegin:            v = ((const begin*)s)->Stmts(); break;
        case uhdmnamed_begin:       v = ((const named_begin*)s)->Stmts(); break;
        case uhdmfork_stmt:         v = ((const fork_stmt*)s)->Stmts(); break;
        case uhdmnamed_fork:        v = ((const named_fork*)s)->Stmts(); break;
        default: return false;
    }
    if (v)
        for (auto* x : *v) out.push_back((const any*)x);
    return true;
}

// The single-statement child relations, so the walk descends THROUGH an if /
// while / foreach / case into the block that may hold the drop.
static void kids(const any* s, std::vector<const any*>& out) {
    if (!s) return;
    switch (s->UhdmType()) {
        case uhdmif_stmt:
            out.push_back(((const if_stmt*)s)->VpiStmt());
            break;
        case uhdmif_else:
            out.push_back(((const if_else*)s)->VpiStmt());
            out.push_back(((const if_else*)s)->VpiElseStmt());
            break;
        case uhdmwhile_stmt:
            out.push_back(((const while_stmt*)s)->VpiStmt());
            break;
        case uhdmfor_stmt:
            out.push_back(((const for_stmt*)s)->VpiStmt());
            break;
        case uhdmforeach_stmt:
            out.push_back(((const foreach_stmt*)s)->VpiStmt());
            break;
        case uhdmdo_while:
            out.push_back(((const do_while*)s)->VpiStmt());
            break;
        case uhdmcase_stmt: {
            auto* ci = ((const case_stmt*)s)->Case_items();
            if (ci)
                for (auto* c : *ci) out.push_back(c->Stmt());
            break;
        }
        default: break;
    }
}

struct Blk {
    const any* node;
    size_t n;
    int depth;
};

static void walk(const any* s, int depth, std::vector<Blk>& blks,
                 std::string& text) {
    if (!s) return;
    for (int i = 0; i < depth; i++) text += "  ";
    text += at((const BaseClass*)s);
    std::vector<const any*> lst;
    bool isList = listOf(s, lst);
    if (isList) {
        text += "  [BLOCK n=" + std::to_string(lst.size()) + "]";
        blks.push_back({s, lst.size(), depth});
    }
    text += "\n";
    for (auto* c : lst) walk(c, depth + 1, blks, text);
    std::vector<const any*> k;
    kids(s, k);
    for (auto* c : k)
        if (c) walk(c, depth + 1, blks, text);
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
    if (d->AllPackages())
        for (auto* p : *d->AllPackages()) {
            if (p->Class_defns())
                for (auto* c : *p->Class_defns()) {
                    if (!scope.empty() && std::string(c->VpiName()) != scope)
                        continue;
                    if (!c->Task_funcs()) continue;
                    for (auto* t : *c->Task_funcs())
                        if (std::string(t->VpiName()) == meth) return t;
                }
        }
    return nullptr;
}

int main(int argc, char** argv) {
    if (argc < 5) {
        std::cout << "usage: svsnest <a.uhdm> <b.uhdm> <class|-> <method>\n";
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
        std::cout << "METHOD NOT FOUND A=" << (ta ? "ok" : "null") << " B="
                  << (tb ? "ok" : "null") << "\n";
        return 3;
    }
    std::vector<Blk> ba, bb;
    std::string txa, txb;
    walk(ta->Stmt(), 1, ba, txa);
    walk(tb->Stmt(), 1, bb, txb);
    std::cout << "A(golden) " << at(ta) << "\n" << (txa.empty() ? "  <no stmt>\n" : txa);
    std::cout << "B(ours)   " << at(tb) << "\n" << (txb.empty() ? "  <no stmt>\n" : txb);
    std::cout << "BLOCKS golden=" << ba.size() << " ours=" << bb.size() << "\n";
    size_t n = ba.size() > bb.size() ? ba.size() : bb.size();
    int bad = 0;
    for (size_t i = 0; i < n; i++) {
        bool ha2 = i < ba.size(), hb2 = i < bb.size();
        std::string v;
        if (!ha2) { v = "ONLY_B_BLOCK"; bad++; }
        else if (!hb2) { v = "ONLY_A_BLOCK"; bad++; }
        else if (ba[i].n != bb[i].n) { v = "*** N MISMATCH ***"; bad++; }
        else v = "n-ok";
        std::cout << "  BLOCK[" << i << "] golden="
                  << (ha2 ? std::to_string(ba[i].n) : "-") << " ours="
                  << (hb2 ? std::to_string(bb[i].n) : "-") << "  " << v << "\n";
    }
    std::cout << "NEST VERDICT " << (bad == 0 ? "ALL BLOCK LENGTHS MATCH" : "MISMATCHES")
              << " bad=" << bad << "\n";
    return 0;
}
