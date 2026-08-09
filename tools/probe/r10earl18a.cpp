// r10earl18a — THE INSTANCE-TOPNESS CENSUS.  Pass 16/17 decoded a whole family
// of "which package copy does this typespec's vpiInstance name" laws one head
// at a time.  This probe answers the question for the WHOLE DESIGN in one run:
// walk every object in the restored arena, and for every typespec that carries
// a vpiInstance which is a PACKAGE, print
//     <tsKind> '<tsName>' @file:line -> <pkgName> top=<0|1>
// deduplicated with an xN count.  Diffing golden's listing against ours names
// every def-vs-top mis-point at once instead of one bisect per head.
//
// Build: bash tools/probe/r10earl18build.sh r10earl18a
// Usage: r10earl18a <a.uhdm> [b.uhdm]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <algorithm>
#include <iostream>
#include <map>
#include <string>
#include <vector>
using namespace UHDM;

static std::string base(std::string_view f) {
    size_t p = f.rfind('/');
    return std::string(p == std::string_view::npos ? f : f.substr(p + 1));
}

static void census(const char* path, const char* tag) {
    Serializer s;
    s.Restore(std::string(path));
    std::map<std::string, int> tally;
    for (auto& kv : s.AllObjects()) {
        auto* o = (const any*)kv.first;
        if (!o)
            continue;
        const typespec* t = any_cast<const typespec*>(o);
        if (!t)
            continue;
        const instance* in = t->Instance();
        if (!in || in->UhdmType() != uhdmpackage)
            continue;
        std::string k = std::string(UhdmName(t->UhdmType())) + " '" +
                        std::string(t->VpiName()) + "' " +
                        base(t->VpiFile()) + ":" +
                        std::to_string(t->VpiLineNo()) + ":" +
                        std::to_string(t->VpiColumnNo()) + " -> " +
                        std::string(in->VpiName()) + " top=" +
                        std::to_string((int)in->VpiTop());
        tally[k]++;
    }
    for (auto& [k, n] : tally)
        std::cout << tag << " x" << n << "  " << k << "\n";
}

int main(int argc, char** argv) {
    if (argc < 2) {
        std::cerr << "usage: r10earl18a <a.uhdm> [b.uhdm]\n";
        return 2;
    }
    census(argv[1], "A");
    if (argc > 2)
        census(argv[2], "B");
    return 0;
}
