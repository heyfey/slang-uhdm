// r10uvm4cmp: run UHDM's own design::Compare and report the failing pair by
// STRUCTURAL IDENTITY (which package view / which module view), which the
// decompile dump cannot show.  SafeCompare reports the CONTAINER on a vector
// size mismatch, so naming the container precisely is the whole game.
//   r10uvm4cmp <golden.uhdm> <ours.uhdm>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <map>
#include <string>
using namespace UHDM;

static std::map<const void*, std::string> tagOf(design* d, const char* side) {
    std::map<const void*, std::string> t;
    for (int top = 0; top < 2; top++) {
        if (auto* l = top ? d->TopPackages() : d->AllPackages())
            for (auto* p : *l)
                t[(const void*)p] = std::string(side) + " pkg " +
                                    std::string(p->VpiName()) +
                                    (top ? "#TOP" : "#DEF");
        if (auto* l = top ? d->TopModules() : d->AllModules())
            for (auto* m : *l)
                t[(const void*)m] = std::string(side) + " mod " +
                                    std::string(m->VpiName()) +
                                    (top ? "#TOP" : "#DEF");
    }
    return t;
}

static void report(const char* side, const BaseClass* o,
                   std::map<const void*, std::string>& t) {
    if (!o) {
        std::cout << side << ": <null>\n";
        return;
    }
    auto it = t.find((const void*)o);
    std::cout << side << ": " << UhdmName(o->UhdmType()) << " '" << o->VpiName()
              << "' " << (it != t.end() ? it->second : std::string("<unlisted>"))
              << " line " << o->VpiLineNo() << "\n";
}

int main(int argc, char** argv) {
    Serializer sa, sb;
    auto ha = sa.Restore(std::filesystem::path(argv[1]));
    auto hb = sb.Restore(std::filesystem::path(argv[2]));
    auto* da = (design*)((uhdm_handle*)ha[0])->object;
    auto* db = (design*)((uhdm_handle*)hb[0])->object;
    auto ta = tagOf(da, "L");
    auto tb = tagOf(db, "R");
    CompareContext ctx;
    int r = da->Compare(db, &ctx);
    std::cout << "r=" << r << "\n";
    report("failLhs", ctx.m_failedLhs, ta);
    report("failRhs", ctx.m_failedRhs, tb);
    return 0;
}
