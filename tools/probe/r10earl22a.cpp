// r10earl22a — WHOLE-ARENA ref_obj BIND census for one source file/line range.
// The corpus witnesses of pass 22 kept failing to reproduce in a small design,
// so this reads the ANSWER straight out of the two big databases: every
// ref_obj whose VpiFile ends with <file> and whose line is in [lo,hi], keyed by
// fullname + line:col, with the Actual_group's TYPE (or "-") as the value.
// Build: bash tools/probe/r10earl22build.sh r10earl22a 22a
// Usage: r10e22_22a <a.uhdm> <b.uhdm> <fileSuffix> <lo> <hi>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <iostream>
#include <map>
#include <set>
#include <string>
using namespace UHDM;

static std::map<std::string, std::string> scan(const std::string& path,
                                               const std::string& suf, int lo,
                                               int hi) {
    static Serializer* keep = nullptr;
    Serializer* ser = new Serializer();
    keep = ser;
    std::map<std::string, std::string> out;
    auto restored = ser->Restore(path);
    if (restored.empty())
        return out;
    for (auto& [obj, id] : ser->AllObjects()) {
        if (!obj || obj->UhdmType() != uhdmref_obj)
            continue;
        // OUR elaborated objects carry an EMPTY VpiFile (the bisector prints
        // `B ref_obj 'x' :147:33` with no name), so the selector is a
        // FULLNAME SUBSTRING, not a file suffix.
        auto* rr = (const ref_obj*)obj;
        std::string fn(rr->VpiFullName());
        if (fn.find(suf) == std::string::npos)
            continue;
        int ln = (int)obj->VpiLineNo();
        if (ln < lo || ln > hi)
            continue;
        auto* r = (const ref_obj*)obj;
        std::string key = std::string(r->VpiFullName()) + "  @" +
                          std::to_string(ln) + ":" +
                          std::to_string(obj->VpiColumnNo());
        std::string val = r->Actual_group()
                              ? std::string(UhdmName(
                                    r->Actual_group()->UhdmType()))
                              : std::string("-");
        auto it = out.find(key);
        if (it == out.end())
            out[key] = val;
        else if (it->second != val)
            it->second += "|" + val;
    }
    return out;
}

int main(int argc, char** argv) {
    if (argc < 6)
        return 1;
    std::string suf = argv[3];
    int lo = atoi(argv[4]), hi = atoi(argv[5]);
    auto A = scan(argv[1], suf, lo, hi);
    auto B = scan(argv[2], suf, lo, hi);
    std::set<std::string> keys;
    for (auto& [k, v] : A)
        keys.insert(k);
    for (auto& [k, v] : B)
        keys.insert(k);
    for (auto& k : keys) {
        auto ia = A.find(k), ib = B.find(k);
        std::string a = ia == A.end() ? "<absent>" : ia->second;
        std::string b = ib == B.end() ? "<absent>" : ib->second;
        std::cout << (a == b ? "ok   " : "DIFF ") << k << "   G=" << a
                  << "  O=" << b << "\n";
    }
    return 0;
}
