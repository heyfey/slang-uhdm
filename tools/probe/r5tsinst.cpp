// `failLhs=package(X) failRhs=<null>` is NOT a package-container mismatch:
// `typespec::Compare` ends with `SafeCompare(lhs->Instance(), rhs->Instance())`,
// and that scalar form sets ONLY m_failedLhs — so the report names the golden
// typespec's OWNING PACKAGE while the real defect is a typespec whose
// `Instance()` (vpiInstance) we leave null.  Enumerate every typespec in both
// serializers (Serializer::AllObjects) and bucket by type+name+location,
// reporting per-bucket population and how many carry an Instance() on each
// side — a bucket holds the def-view and top-view twins together, so counts,
// not a single representative, are what identify the missing binding.
#include <uhdm/Serializer.h>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <uhdm/vpi_visitor.h>

#include <filesystem>
#include <iostream>
#include <map>
#include <set>
#include <string>
#include <vector>
using namespace UHDM;

struct Bucket {
    int n = 0;
    int withInst = 0;
    int withAlias = 0;
    std::set<std::string> instNames;
};

static std::string key(const typespec* t) {
    return std::string(UhdmName(t->UhdmType())) + "|" + std::string(t->VpiName()) +
           "|" + std::to_string(t->VpiLineNo()) + ":" +
           std::to_string(t->VpiColumnNo());
}

static void collect(Serializer& s, std::map<std::string, Bucket>& out) {
    for (auto& [o, id] : s.AllObjects()) {
        if (!o) continue;
        const typespec* t = dynamic_cast<const typespec*>(o);
        if (!t) continue;
        Bucket& b = out[key(t)];
        b.n++;
        if (const any* i = t->Instance()) {
            b.withInst++;
            b.instNames.insert(std::string(UhdmName(i->UhdmType())) + "(" +
                               std::string(i->VpiName()) + ")");
        }
        if (t->Typedef_alias()) b.withAlias++;
    }
}

static std::string names(const Bucket& b) {
    std::string r;
    for (auto& n : b.instNames) r += (r.empty() ? "" : ",") + n;
    return r.empty() ? "-" : r;
}

int main(int argc, char** argv) {
    Serializer sa, sb;
    sa.Restore(std::filesystem::path(argv[1]));
    sb.Restore(std::filesystem::path(argv[2]));
    std::map<std::string, Bucket> ma, mb;
    collect(sa, ma);
    collect(sb, mb);
    std::set<std::string> keys;
    for (auto& [k, v] : ma) keys.insert(k);
    for (auto& [k, v] : mb) keys.insert(k);
    for (auto& k : keys) {
        Bucket a = ma.count(k) ? ma[k] : Bucket();
        Bucket b = mb.count(k) ? mb[k] : Bucket();
        if (a.n == b.n && a.withInst == b.withInst && a.withAlias == b.withAlias &&
            a.instNames == b.instNames)
            continue;
        std::cout << (a.withInst != b.withInst || a.instNames != b.instNames
                          ? "INST "
                          : (a.withAlias != b.withAlias ? "ALIAS" : "COUNT"))
                  << " " << k << "  golden[n=" << a.n << " inst=" << a.withInst
                  << " alias=" << a.withAlias << " " << names(a) << "]"
                  << "  slang[n=" << b.n << " inst=" << b.withInst << " alias="
                  << b.withAlias << " " << names(b) << "]\n";
    }
    return 0;
}
