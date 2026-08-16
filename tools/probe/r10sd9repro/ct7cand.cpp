// r10sd7 — THE CANDIDATE JOIN.  Every object that carries a singular
// `vpiInstance`, keyed by (kind | name | span | parent chain), joined golden
// against ours, reporting the keys where GOLDEN IS NULL AND OURS IS NOT.
//
// WHY IT REPLACES THE BACKTRACE.  sd4's `ct4bt` method — a hardware watchpoint
// on `CompareContext::m_failedRhs` — is still the right way to learn the ARM.
// Its FRAME NAMES are not trustworthy in this binary, and this pass proved that
// rather than assuming it: gdb's live `bt` symbolised the return address
// `0x778f6e` as `array_typespec::Compare`, while `info symbol` on the very same
// non-PIE executable resolves it to `logic_typespec::Compare + 142`
// (`array_typespec::Compare` starts at `0x779190`, two symbols later).  Acting on
// the frame name cost this pass three census instruments, each of which came
// back "the two sides agree" — which they do.
//
// The head is `LHS:<null>` / `RHS: package(uvm_pkg)`, and `SafeCompare`
// (`BaseClass.h`:194-196) writes `m_failedRhs` with an unset `m_failedLhs` in
// EXACTLY ONE branch: `lhs == nullptr && rhs != nullptr`.  The only singular
// slot in these databases that can hold a `package` is `vpiInstance` (sd2's
// 154-relation census).  So the failing pair is an object whose golden twin's
// `vpiInstance` is NULL and whose OURS twin's is that package — and that pair is
// enumerable directly, without reading a single frame.
//
// GUARD: an empty candidate set is reported as a hard error, because "no
// candidates" and "the tool reached nothing" print the same otherwise.
//
// build: g++ -O2 -std=c++17 ct7cand.cpp -I ~/.local/include \
//          -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct7cand
// usage: ct7cand <golden.uhdm> <ours.uhdm>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <map>
#include <set>
#include <string>
#include <vector>

using namespace UHDM;

static std::string span(const BaseClass* p) {
    return std::to_string(p->VpiLineNo()) + ":" + std::to_string(p->VpiColumnNo()) + "-" +
           std::to_string(p->VpiEndLineNo()) + ":" + std::to_string(p->VpiEndColumnNo());
}
static std::string ident(const BaseClass* p) {
    if (!p) return "<null>";
    std::string s = UhdmName(p->UhdmType());
    std::string nm(p->VpiName());
    if (!nm.empty()) s += "(" + nm + ")";
    return s + "@" + span(p);
}
// The key deliberately EXCLUDES VpiFile: our emission leaves it empty on most
// typespecs (sd2 R7), and a file-keyed join reads green by matching nothing.
static std::string key(const BaseClass* p) {
    std::string k = ident(p);
    const BaseClass* q = p->VpiParent();
    for (int i = 0; i < 3 && q; i++) { k += " <- " + ident(q); q = q->VpiParent(); }
    return k;
}

struct Side {
    std::map<std::string, std::vector<const instance*>> inst;  // key -> instances
    std::set<const BaseClass*> allp, topp;
    std::string view(const instance* i) const {
        if (!i) return "<null>";
        std::string nm(i->VpiName());
        if (topp.count(i)) return "TOP:" + nm;
        if (allp.count(i)) return "ALL:" + nm;
        return "OTHER:" + nm;
    }
};

static void load(const char* path, Side& S, size_t& nobj) {
    static Serializer s1, s2;
    static int which = 0;
    Serializer& s = (which++ == 0) ? s1 : s2;
    auto h = s.Restore(std::filesystem::path(path));
    if (h.empty()) { std::cerr << "RESTORE FAILED " << path << "\n"; exit(3); }
    auto* d = (design*)((uhdm_handle*)h[0])->object;
    if (auto* v = d->AllPackages()) for (auto* p : *v) S.allp.insert(p);
    if (auto* v = d->TopPackages()) for (auto* p : *v) S.topp.insert(p);
    for (const auto& [obj, id] : s.AllObjects()) {
        if (!obj) continue;
        nobj++;
        const instance* in = nullptr;
        bool has = false;
        if (auto* t = any_cast<const typespec*>((const any*)obj)) { in = t->Instance(); has = true; }
        else if (auto* v = any_cast<const variables*>((const any*)obj)) { in = v->Instance(); has = true; }
        if (!has) continue;
        S.inst[key(obj)].push_back(in);
    }
}

int main(int argc, char** argv) {
    if (argc < 3) { std::cerr << "usage: ct7cand <golden> <ours>\n"; return 2; }
    Side G, O;
    size_t ng = 0, no = 0;
    load(argv[1], G, ng);
    load(argv[2], O, no);
    std::cout << "objects: golden=" << ng << " ours=" << no
              << "   instance-bearing keys: golden=" << G.inst.size()
              << " ours=" << O.inst.size() << "\n";
    // THE CANDIDATE SET: a key where every golden copy is NULL and at least one
    // of ours is NOT.  That is the exact shape SafeCompare's `lhs==nullptr &&
    // rhs!=nullptr` branch reports.
    size_t cand = 0;
    std::map<std::string, int> byKind;
    for (auto& [k, ov] : O.inst) {
        auto it = G.inst.find(k);
        if (it == G.inst.end()) continue;          // no golden twin at this key
        bool gAllNull = true;
        for (auto* i : it->second) if (i) gAllNull = false;
        if (!gAllNull) continue;
        for (auto* i : ov) {
            if (!i) continue;
            cand++;
            std::cout << "CAND " << O.view(i) << "   " << k << "\n";
            byKind[std::string(k.substr(0, k.find('(') == std::string::npos
                                               ? k.find('@')
                                               : k.find('('))) +
                   "  " + O.view(i)]++;
            break;
        }
    }
    std::cout << "[S] CANDIDATES=" << cand << "\n";
    for (auto& [k, v] : byKind) std::cout << "    " << v << "\t" << k << "\n";
    if (cand == 0) {
        std::cerr << "REFUSING TO REPORT: zero candidates — either the key is "
                     "too strict or the head is not this shape\n";
        return 5;
    }
    return 0;
}
