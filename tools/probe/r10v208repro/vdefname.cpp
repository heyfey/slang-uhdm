// r10v208 — is VpiDefName ever set on an (packed_)array_typespec?  § 208's
// copyTsShell208 does NOT copy VpiDefName, and BaseClass::Compare READS it.
#include <uhdm/uhdm.h>
#include <cstdio>
#include <string>
using namespace UHDM;
int main(int argc, char** argv) {
    for (int i = 1; i < argc; ++i) {
        Serializer s; s.Restore(std::string(argv[i]));
        long n = 0, nd = 0, refs = 0, refd = 0;
        for (auto& kv : s.AllObjects()) {
            auto* o = (BaseClass*)kv.first; if (!o) continue;
            auto t = o->UhdmType();
            if (t == uhdmarray_typespec || t == uhdmpacked_array_typespec) {
                ++n; if (!o->VpiDefName().empty()) { ++nd;
                    printf("DEFNAME %s array_ts name='%s' defname='%s'\n", argv[i],
                           std::string(o->VpiName()).c_str(),
                           std::string(o->VpiDefName()).c_str()); }
            }
            if (t == uhdmref_typespec) { ++refs; if (!o->VpiDefName().empty()) ++refd; }
        }
        printf("%s arrays=%ld with-defname=%ld refs=%ld ref-with-defname=%ld\n",
               argv[i], n, nd, refs, refd);
    }
    return 0;
}
