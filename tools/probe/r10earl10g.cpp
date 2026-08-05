// r10earl10g: print a DEF-view gen region's statement list on both sides.
// uhdm-cmp reports "named_begin 'X'" heads with r=1 = vector SIZE mismatch;
// this names WHICH statement is missing.
// Usage: r10earl10g <a.uhdm> <b.uhdm> <blockName> [defNameFilter]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <string>
#include <vector>
using namespace UHDM;

static std::string one(const any* n) {
    if (!n) return "<null>";
    std::string s = std::string(UhdmName(n->UhdmType())) + " '" +
                    std::string(n->VpiName()) + "' " +
                    std::string(n->VpiFile()) + ":" +
                    std::to_string(n->VpiLineNo()) + ":" +
                    std::to_string(n->VpiColumnNo());
    return s;
}

static std::string g_want;

static void dumpBlock(const any* b, const char* side) {
    const VectorOfany* st = nullptr;
    if (b->UhdmType() == uhdmnamed_begin) st = ((const named_begin*)b)->Stmts();
    else if (b->UhdmType() == uhdmbegin) st = ((const begin*)b)->Stmts();
    std::cout << "  [" << side << "] " << one(b) << "  n="
              << (st ? st->size() : 0) << "\n";
    if (st)
        for (size_t i = 0; i < st->size(); i++) {
            const any* x = (*st)[i];
            std::cout << "      " << i << ": " << one(x) << "\n";
            if (x->UhdmType() == uhdmassignment) {
                auto* a = (const assignment*)x;
                std::cout << "          op=" << a->VpiOpType()
                          << " blocking=" << (int)a->VpiBlocking()
                          << " Lhs=" << one(a->Lhs())
                          << " Rhs=" << one(a->Rhs()) << "\n";
                if (auto* e = any_cast<const expr*>(a->Lhs())) {
                    auto* r = e->Typespec();
                    std::cout << "          Lhs.ts=";
                    if (!r) std::cout << "<null>\n";
                    else {
                        auto* act = r->Actual_typespec();
                        std::cout << "rts full='" << r->VpiFullName() << "' -> "
                                  << (act ? one(act) : "<null>") << "\n";
                    }
                }
            }
        }
}

// generic recursion over gen_stmt trees
static void walkGen(const any* g, const char* side);

static void walkAnyBlock(const any* b, const char* side) {
    if (!b) return;
    if (b->UhdmType() == uhdmnamed_begin || b->UhdmType() == uhdmbegin) {
        if (std::string(b->VpiName()) == g_want) dumpBlock(b, side);
        const VectorOfany* st = nullptr;
        if (b->UhdmType() == uhdmnamed_begin) st = ((const named_begin*)b)->Stmts();
        else st = ((const begin*)b)->Stmts();
        if (st)
            for (auto* x : *st) walkGen(x, side);
    }
}

static void walkGen(const any* g, const char* side) {
    if (!g) return;
    switch (g->UhdmType()) {
        case uhdmgen_region: {
            auto* gr = (const gen_region*)g;
            walkGen(gr->VpiStmt(), side);
            break;
        }
        case uhdmgen_for: {
            auto* gf = (const gen_for*)g;
            walkAnyBlock(gf->VpiStmt(), side);
            break;
        }
        case uhdmgen_if: {
            auto* gi = (const gen_if*)g;
            walkAnyBlock(gi->VpiStmt(), side);
            break;
        }
        case uhdmgen_if_else: {
            auto* gi = (const gen_if_else*)g;
            walkAnyBlock(gi->VpiStmt(), side);
            walkAnyBlock(gi->VpiElseStmt(), side);
            break;
        }
        case uhdmgen_case: {
            auto* gc = (const gen_case*)g;
            if (gc->Case_items())
                for (auto* ci : *gc->Case_items()) walkAnyBlock(ci->Stmt(), side);
            break;
        }
        case uhdmnamed_begin:
        case uhdmbegin:
            walkAnyBlock(g, side);
            break;
        default:
            break;
    }
}

static void scan(const design* d, const char* side, const std::string& filter) {
    auto* am = d->AllModules();
    if (!am) return;
    for (auto* m : *am) {
        if (!filter.empty() &&
            std::string(m->VpiDefName()).find(filter) == std::string::npos)
            continue;
        if (m->Gen_stmts())
            for (auto* g : *m->Gen_stmts()) walkGen(g, side);
    }
}

int main(int argc, char** argv) {
    if (argc < 4) return 1;
    g_want = argv[3];
    std::string filter = argc > 4 ? argv[4] : "";
    Serializer sa, sb;
    auto ha = sa.Restore(std::filesystem::path(argv[1]));
    auto hb = sb.Restore(std::filesystem::path(argv[2]));
    if (ha.empty() || hb.empty()) return 2;
    const design* da = (const design*)((uhdm_handle*)ha[0])->object;
    const design* db = (const design*)((uhdm_handle*)hb[0])->object;
    scan(da, "G", filter);
    scan(db, "O", filter);
    return 0;
}
