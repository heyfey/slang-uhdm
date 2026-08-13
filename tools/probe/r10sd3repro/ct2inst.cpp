// r10sd2 — WHOLE-DATABASE CENSUS OF `vpiInstance` (the singular `Instance()`
// field), SPAN-KEYED, BOTH SIDES.
//
// Seven UHDM classes carry a singular `Instance()` that `Compare` reads:
//   variables, task_func, typespec, ports, clocking_block, instance
// (gen_scope_array carries `VpiInstance()`, a different accessor, also read).
// The r10sd2 head — `LHS:<null>` / `RHS: package uvm_pkg` — is the
// `(lhs==nullptr && rhs!=nullptr)` SINGULAR arm of `BaseClass::SafeCompare`, so
// SOME object of those classes has `Instance()==nullptr` in golden and
// `==package(uvm_pkg)` in ours.  This tool reads every object out of the
// Serializer (no traversal, no recursion, nothing hidden behind `m_visited`),
// keys it by (uhdmType, name, file:line:col), and prints the census.
//
// build: g++ -O2 -std=c++17 ct2inst.cpp -I ~/.local/include \
//          -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct2inst
// usage: ct2inst <golden.uhdm> <ours.uhdm> [maxlist]
#include <uhdm/uhdm.h>

#include <filesystem>
#include <iostream>
#include <map>
#include <sstream>
#include <string>
#include <vector>

using namespace UHDM;

struct Rec {
    std::string inst;   // "<null>" or "package(uvm_pkg)" etc
    std::string owner;  // uhdm type name
};

static std::string ident(const BaseClass* p) {
    if (!p) return "<null>";
    std::string s = UhdmName(p->UhdmType());
    std::string nm(p->VpiName());
    if (!nm.empty()) s += "(" + nm + ")";
    return s;
}

// Returns true if this object type carries a singular Instance() that Compare
// reads, and writes it to `out`.
static bool instOf(const BaseClass* o, const BaseClass*& out) {
    switch (o->UhdmType()) {
        default: break;
    }
    if (const variables* v = any_cast<const variables*>(o)) {
        out = v->Instance();
        return true;
    }
    if (const task_func* t = any_cast<const task_func*>(o)) {
        out = t->Instance();
        return true;
    }
    if (const typespec* t = any_cast<const typespec*>(o)) {
        out = t->Instance();
        return true;
    }
    if (const ports* p = any_cast<const ports*>(o)) {
        out = p->Instance();
        return true;
    }
    if (const clocking_block* c = any_cast<const clocking_block*>(o)) {
        out = c->Instance();
        return true;
    }
    if (const instance* i = any_cast<const instance*>(o)) {
        out = i->Instance();
        return true;
    }
    return false;
}

static void collect(const char* path, std::map<std::string, Rec>& m,
                    std::map<std::string, int>& dup) {
    Serializer s;
    auto h = s.Restore(std::filesystem::path(path));
    if (h.empty()) {
        std::cerr << "RESTORE_FAIL " << path << "\n";
        exit(3);
    }
    for (const auto& [obj, id] : s.AllObjects()) {
        if (!obj) continue;
        const BaseClass* inst = nullptr;
        if (!instOf(obj, inst)) continue;
        // NB: VpiFile is DELIBERATELY NOT in the key.  Our emission leaves
        // VpiFile EMPTY on nearly every object while Surelog fills it, so a
        // file-keyed census shares 35 keys out of 20 000 and reads as "no
        // divergence" — measured, and the reason this line carries a comment.
        // VpiFile is read by no Compare body, so dropping it is also faithful
        // to what the head can possibly be about.
        std::ostringstream k;
        k << UhdmName(obj->UhdmType()) << "|" << obj->VpiName() << "|"
          << obj->VpiLineNo() << ":" << obj->VpiColumnNo() << "-"
          << obj->VpiEndLineNo() << ":" << obj->VpiEndColumnNo();
        std::string key = k.str();
        std::string val = ident(inst);
        auto it = m.find(key);
        if (it == m.end()) {
            m[key] = Rec{val, UhdmName(obj->UhdmType())};
        } else {
            dup[key]++;
            if (it->second.inst != val) it->second.inst = "<MIXED>";
        }
    }
}

int main(int argc, char** argv) {
    if (argc < 3) {
        std::cerr << "usage: ct2inst <golden.uhdm> <ours.uhdm> [maxlist]\n";
        return 2;
    }
    int maxlist = argc > 3 ? atoi(argv[3]) : 25;
    std::map<std::string, Rec> G, O;
    std::map<std::string, int> gdup, odup;
    collect(argv[1], G, gdup);
    collect(argv[2], O, odup);
    std::cout << "keys: golden=" << G.size() << " ours=" << O.size() << "\n";

    // The head's shape: golden <null>, ours non-null.
    std::map<std::string, int> byOwnerHead, byOwnerRev, byOwnerDiff, byOwnerSame;
    std::map<std::string, int> headInstName;
    std::vector<std::string> headEx;
    for (const auto& [k, r] : G) {
        auto it = O.find(k);
        if (it == O.end()) continue;
        const std::string& go = r.inst;
        const std::string& ou = it->second.inst;
        if (go == ou) {
            byOwnerSame[r.owner]++;
            continue;
        }
        if (go == "<null>" && ou != "<null>") {
            byOwnerHead[r.owner]++;
            headInstName[ou]++;
            if ((int)headEx.size() < maxlist)
                headEx.push_back(k + "   golden=<null> ours=" + ou);
        } else if (go != "<null>" && ou == "<null>") {
            byOwnerRev[r.owner]++;
        } else {
            byOwnerDiff[r.owner]++;
        }
    }
    auto pr = [](const char* tag, const std::map<std::string, int>& m) {
        int tot = 0;
        std::cout << tag << ":";
        for (const auto& [k, v] : m) {
            std::cout << " " << k << "=" << v;
            tot += v;
        }
        std::cout << "   TOTAL=" << tot << "\n";
    };
    pr("SAME              (shared keys)", byOwnerSame);
    pr("HEAD golden<null> ours=OBJ     ", byOwnerHead);
    pr("REV  golden=OBJ   ours=<null>  ", byOwnerRev);
    pr("BOTH non-null, DIFFERENT       ", byOwnerDiff);
    std::cout << "HEAD instance values:";
    for (const auto& [k, v] : headInstName) std::cout << " [" << k << "]=" << v;
    std::cout << "\n";
    std::cout << "HEAD examples (max " << maxlist << "):\n";
    for (const auto& e : headEx) std::cout << "  " << e << "\n";
    return 0;
}
