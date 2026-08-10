// r10earl23a — WHOLE-ARENA OBJECT census keyed by VpiFullName substring.
// Pass 22's r10earl22a answers "is this ref bound?"; this one answers "does
// this OBJECT EXIST AT ALL, and with what type?", which is the question a
// `VECTOR SIZE 20 vs 18` note asks.  Every object whose VpiFullName contains
// <substr> (and, optionally, whose UhdmName contains <typeSubstr>) is printed
// as `<type> <fullname> @line:col` with an xN count, diffed between the two
// databases.
// Build: bash tools/probe/r10earl23build.sh r10earl23a 23a
// Usage: r10e23_23a <a.uhdm> <b.uhdm> <fullnameSubstr> [typeSubstr] [lo] [hi]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <iostream>
#include <map>
#include <set>
#include <string>
using namespace UHDM;

static std::map<std::string, int> scan(const std::string& path,
                                       const std::string& sub,
                                       const std::string& tsub, int lo,
                                       int hi) {
    Serializer* ser = new Serializer();  // leaked on purpose: keeps objects live
    std::map<std::string, int> out;
    auto restored = ser->Restore(path);
    if (restored.empty())
        return out;
    for (auto& [obj, id] : ser->AllObjects()) {
        if (!obj)
            continue;
        std::string ty(UhdmName(obj->UhdmType()));
        if (!tsub.empty() && ty.find(tsub) == std::string::npos)
            continue;
        std::string fn;
        if (const any* a = (const any*)obj) {
            if (const auto* n = any_cast<const scope*>(a))
                fn = n->VpiFullName();
        }
        if (fn.empty()) {
            // VpiFullName lives on many unrelated classes; go through the
            // generic vpi accessor so no per-type list is needed.
            vpiHandle h = NewVpiHandle((const any*)obj);
            const char* s = vpi_get_str(vpiFullName, h);
            if (s)
                fn = s;
            vpi_release_handle(h);
        }
        if (fn.find(sub) == std::string::npos)
            continue;
        int ln = (int)obj->VpiLineNo();
        if (lo >= 0 && (ln < lo || ln > hi))
            continue;
        out[ty + "  " + fn + " @" + std::to_string(ln) + ":" +
            std::to_string(obj->VpiColumnNo())]++;
    }
    return out;
}

int main(int argc, char** argv) {
    if (argc < 4)
        return 1;
    std::string sub = argv[3];
    std::string tsub = argc > 4 ? argv[4] : "";
    int lo = argc > 6 ? atoi(argv[5]) : -1;
    int hi = argc > 6 ? atoi(argv[6]) : -1;
    auto A = scan(argv[1], sub, tsub, lo, hi);
    auto B = scan(argv[2], sub, tsub, lo, hi);
    std::set<std::string> keys;
    for (auto& [k, v] : A)
        keys.insert(k);
    for (auto& [k, v] : B)
        keys.insert(k);
    for (auto& k : keys) {
        int a = A.count(k) ? A[k] : 0;
        int b = B.count(k) ? B[k] : 0;
        std::cout << (a == b ? "ok   " : "DIFF ") << "G=x" << a << " O=x" << b
                  << "   " << k << "\n";
    }
    return 0;
}
