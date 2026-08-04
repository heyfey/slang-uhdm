// r10bbp10c: OWNERSHIP-PATH probe.  uhdm-cmp's CompareContext names the object
// that failed but never the slot chain that reached it, and VpiParent is only
// the creating parent — not necessarily the slot the comparison walked.  This
// listens over a whole design with UhdmListener and, for every object whose
// UhdmId matches one of the requested ids, prints the LISTENER CALLSTACK: the
// real containment path the traversal took to get there.
// Build:
//   g++ -std=c++20 -O1 tools/probe/r10bbp10c.cpp -o /tmp/r10bbp10cq \
//       -I$HOME/.local/include $HOME/.local/lib64/libuhdm.a \
//       $HOME/.local/lib64/libcapnp.a $HOME/.local/lib64/libkj.a -lpthread
// Usage: r10bbp10cq <db.uhdm> <id>[,<id>...]
#include <uhdm/UhdmListener.h>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <set>
#include <string>
using namespace UHDM;

static std::set<uint32_t> wanted;

static std::string at(const any* n) {
    if (!n) return "<null>";
    return std::string(UhdmName(n->UhdmType())) + " id" +
           std::to_string(n->UhdmId()) + " '" + std::string(n->VpiName()) +
           "' " + std::to_string(n->VpiLineNo()) + ":" +
           std::to_string(n->VpiColumnNo());
}

class Hunter : public UhdmListener {
 public:
    void enterAny(const any* const object) override {
        if (!object) return;
        if (wanted.find(object->UhdmId()) == wanted.end()) return;
        std::cout << "HIT " << at(object) << "\n";
        int i = 0;
        for (auto it = getCallstack().crbegin(); it != getCallstack().crend();
             ++it) {
            std::cout << "   [" << i++ << "] " << at(*it) << "\n";
            if (i > 16) break;
        }
        std::cout << "\n";
    }
};

int main(int argc, char** argv) {
    if (argc < 3) return 1;
    std::string ids(argv[2]);
    size_t p = 0;
    while (p < ids.size()) {
        size_t q = ids.find(',', p);
        if (q == std::string::npos) q = ids.size();
        wanted.insert((uint32_t)atoll(ids.substr(p, q - p).c_str()));
        p = q + 1;
    }
    Serializer ser;
    auto h = ser.Restore(std::filesystem::path(argv[1]));
    if (h.empty()) return 2;
    const design* d = (const design*)((uhdm_handle*)h[0])->object;
    Hunter hunter;
    hunter.listenAny(d);
    std::cout << "== done\n";
    return 0;
}
