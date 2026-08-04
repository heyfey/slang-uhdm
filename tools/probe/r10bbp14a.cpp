// r10bbp14a: the TRUE whole-design head.  Runs design::Compare with ONE shared
// CompareContext (exactly what uhdm-cmp does) and prints the failing pair with
// enough identity (UhdmId, parent chain by VpiParent, vpiImported) to name the
// object.  Then re-runs per top-level vector with a FRESH context so the slot
// that carries the head is named too.
// Build:
//   g++ -std=c++20 -O1 tools/probe/r10bbp14a.cpp -o /tmp/r10bbp14aq \
//       -I$HOME/.local/include $HOME/.local/lib64/libuhdm.a \
//       $HOME/.local/lib64/libcapnp.a $HOME/.local/lib64/libkj.a -lpthread
// Usage: r10bbp14aq <golden.uhdm> <ours.uhdm>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <string>
using namespace UHDM;

static std::string at(const BaseClass* n) {
    if (!n) return "<null>";
    std::string s = std::string(UhdmName(n->UhdmType())) + " id" +
                    std::to_string(n->UhdmId()) + " '" +
                    std::string(n->VpiName()) + "' " +
                    std::to_string(n->VpiLineNo()) + ":" +
                    std::to_string(n->VpiColumnNo());
    if (n->UhdmType() == uhdmconstant) {
        auto* c = (const constant*)n;
        s += " {ct=" + std::to_string(c->VpiConstType()) +
             " sz=" + std::to_string(c->VpiSize()) + " dec=" +
             std::string(c->VpiDecompile()) + "}";
    }
    if (n->UhdmType() == uhdmparameter) {
        auto* p = (const parameter*)n;
        s += " {imported='" + std::string(p->VpiImported()) +
             "' local=" + std::to_string(p->VpiLocalParam()) + "}";
    }
    return s;
}

static std::string chain(const BaseClass* n) {
    std::string s;
    int i = 0;
    const any* p = n ? n->VpiParent() : nullptr;
    while (p && i++ < 8) {
        s += "\n      ^ " + at(p);
        p = p->VpiParent();
    }
    return s;
}

static void rep(const char* tag, CompareContext& ctx, int r) {
    std::cout << tag << ": r=" << r << "\n";
    if (r == 0) return;
    std::cout << "   failLhs " << at(ctx.m_failedLhs) << chain(ctx.m_failedLhs)
              << "\n   failRhs " << at(ctx.m_failedRhs) << chain(ctx.m_failedRhs)
              << "\n";
}

int main(int argc, char** argv) {
    if (argc < 3) return 1;
    Serializer sa, sb;
    auto ha = sa.Restore(std::filesystem::path(argv[1]));
    auto hb = sb.Restore(std::filesystem::path(argv[2]));
    if (ha.empty() || hb.empty()) return 2;
    const design* da = (const design*)((uhdm_handle*)ha[0])->object;
    const design* db = (const design*)((uhdm_handle*)hb[0])->object;
    {
        CompareContext ctx;
        rep("DESIGN(shared)", ctx, da->Compare(db, &ctx));
    }
    auto go = [&](const char* tag, auto* va, auto* vb) {
        size_t na = va ? va->size() : 0, nb = vb ? vb->size() : 0;
        if (na != nb) {
            std::cout << tag << ": SIZE " << na << " vs " << nb << "\n";
            return;
        }
        for (size_t i = 0; i < na; i++) {
            CompareContext ctx;
            int r = (*va)[i]->Compare((*vb)[i], &ctx);
            if (r == 0) continue;
            rep((std::string(tag) + "[" + std::to_string(i) + "]" +
                 std::string((*va)[i]->VpiName()))
                    .c_str(),
                ctx, r);
        }
    };
    go("ALLPKG", da->AllPackages(), db->AllPackages());
    go("ALLMOD", da->AllModules(), db->AllModules());
    go("TOPMOD", da->TopModules(), db->TopModules());
    std::cout << "== done\n";
    return 0;
}
