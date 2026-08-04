// r10uvm6m: struct/union MEMBER typespec projection — object id, name and
// whether the member's copy carries a Typedef_alias.  The member copy is the
// one shape LAW S's variable walk cannot see (a typespec_member is not a
// `variables`), and the alias half decides which of the two copy shapes it
// takes.
//   r10uvm6m <file.uhdm>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <map>
#include <string>
using namespace UHDM;

static std::map<const void*, long> ids;
static long idOf(const void* p) {
    if (!p) return -1;
    auto it = ids.find(p);
    if (it != ids.end()) return it->second;
    long n = (long)ids.size() + 1;
    ids[p] = n;
    return n;
}

int main(int argc, char** argv) {
    Serializer s;
    auto h = s.Restore(std::filesystem::path(argv[1]));
    (void)h;
    for (auto& kv : s.AllObjects()) {
        const BaseClass* o = kv.first;
        if (!o) continue;
        auto* a = (const any*)o;
        const VectorOftypespec_member* ms = nullptr;
        if (a->UhdmType() == uhdmstruct_typespec)
            ms = ((const struct_typespec*)a)->Members();
        else if (a->UhdmType() == uhdmunion_typespec)
            ms = ((const union_typespec*)a)->Members();
        if (!ms) continue;
        for (auto* m : *ms) {
            auto* rt = m->Typespec();
            auto* at = rt ? rt->Actual_typespec() : nullptr;
            if (!at) continue;
            auto* al = ((typespec*)at)->Typedef_alias();
            std::cout << std::string(a->VpiName()) << "." << std::string(m->VpiName())
                      << " -> #" << idOf((const void*)at) << " "
                      << UhdmName(at->UhdmType()) << " '"
                      << std::string(at->VpiName()) << "' inst=#"
                      << idOf((const void*)at->Instance()) << " alias="
                      << (al ? (al->Actual_typespec()
                                    ? "'" + std::string(
                                                al->Actual_typespec()->VpiName()) +
                                          "'"
                                    : std::string("<empty>"))
                             : std::string("-"))
                      << "\n";
        }
    }
    return 0;
}
