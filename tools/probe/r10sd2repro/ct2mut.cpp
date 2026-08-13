// r10sd2 — MUTATION PROBE: null `vpiInstance` on OUR side, one owner TYPE at a
// time, and read what `Compare` says next.
//
// The head is the singular `LHS:<null>` arm and `ct2ptr.cpp` shows that in these
// databases EVERY slot that can hold `package uvm_pkg` is `vpiInstance`.  So the
// head is a `vpiInstance` we set and golden does not.  Which owner type?  Ask
// `Compare`, by removing one type's `vpiInstance` from our in-memory copy and
// re-running the whole-design comparison.  Nothing is serialised; this never
// touches a database on disk.
//
// build: g++ -O2 -std=c++17 ct2mut.cpp -I ~/.local/include \
//          -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct2mut
// usage: ct2mut <golden.uhdm> <ours.uhdm> [onlyType]
#include <uhdm/uhdm.h>

#include <filesystem>
#include <iostream>
#include <map>
#include <set>
#include <string>
#include <vector>

using namespace UHDM;

static std::string ident(const BaseClass* p) {
    if (!p) return "<null>";
    std::string s = UhdmName(p->UhdmType());
    std::string nm(p->VpiName());
    if (!nm.empty()) s += "(" + nm + ")";
    s += "@" + std::to_string(p->VpiLineNo()) + ":" +
         std::to_string(p->VpiColumnNo()) + "-" +
         std::to_string(p->VpiEndLineNo()) + ":" +
         std::to_string(p->VpiEndColumnNo());
    return s;
}

static void report(const std::string& tag, const design* g, const design* o) {
    CompareContext c;
    int r = g->Compare(o, &c);
    std::cout << tag << "  r=" << r << "  LHS=" << ident(c.m_failedLhs)
              << "  RHS=" << ident(c.m_failedRhs) << "\n";
}

int main(int argc, char** argv) {
    if (argc < 3) {
        std::cerr << "usage: ct2mut <golden.uhdm> <ours.uhdm> [onlyType]\n";
        return 2;
    }
    std::string only = argc > 3 ? argv[3] : "";
    Serializer sa, sb;
    auto ha = sa.Restore(std::filesystem::path(argv[1]));
    auto hb = sb.Restore(std::filesystem::path(argv[2]));
    auto* da = (design*)((uhdm_handle*)ha[0])->object;
    auto* db = (design*)((uhdm_handle*)hb[0])->object;
    report("BASELINE                     ", da, db);

    // Collect our typespec objects by type, and remember their Instance so each
    // mutation can be undone before the next one runs.
    std::map<std::string, std::vector<typespec*>> byType;
    for (const auto& [p, id] : sb.AllObjects()) {
        typespec* t = any_cast<typespec*>(const_cast<BaseClass*>(p));
        if (!t || !t->Instance()) continue;
        byType[UhdmName(t->UhdmType())].push_back(t);
    }
    for (auto& [ty, v] : byType) {
        if (!only.empty() && ty != only) continue;
        std::vector<const instance*> saved;
        saved.reserve(v.size());
        for (typespec* t : v) {
            saved.push_back(t->Instance());
            t->Instance(nullptr);
        }
        report("null " + ty + ".vpiInstance (" + std::to_string(v.size()) + ")",
               da, db);
        for (size_t i = 0; i < v.size(); i++)
            v[i]->Instance(const_cast<instance*>(saved[i]));
    }
    // BISECT WITHIN ONE TYPE: which single object's vpiInstance is the head?
    // `test(S)` nulls S and asks whether the `LHS:<null>` / `RHS: package` arm
    // survives; the head's owner is the last singleton that kills it.
    if (!only.empty() && byType.count(only)) {
        auto& v = byType[only];
        auto test = [&](const std::vector<typespec*>& s) {
            std::vector<const instance*> saved;
            for (typespec* t : s) { saved.push_back(t->Instance()); t->Instance(nullptr); }
            CompareContext c;
            int r = da->Compare(db, &c);
            bool alive = r != 0 && c.m_failedLhs == nullptr &&
                         c.m_failedRhs &&
                         c.m_failedRhs->UhdmType() == UHDM_OBJECT_TYPE::uhdmpackage;
            for (size_t i = 0; i < s.size(); i++)
                s[i]->Instance(const_cast<instance*>(saved[i]));
            return alive;
        };
        std::vector<typespec*> cand = v;
        while (cand.size() > 1) {
            size_t h = cand.size() / 2;
            std::vector<typespec*> a(cand.begin(), cand.begin() + h);
            std::vector<typespec*> b(cand.begin() + h, cand.end());
            if (!test(a)) cand = a;
            else if (!test(b)) cand = b;
            else { std::cout << "BISECT STALLED at " << cand.size() << "\n"; break; }
        }
        std::cout << "\n>>> BISECT " << only << ": " << cand.size()
                  << " candidate(s)\n";
        for (typespec* t : cand) {
            std::cout << ">>> " << ident(t) << "  file=" << t->VpiFile()
                      << "  inst=" << ident(t->Instance()) << "\n";
            int guard = 0;
            std::cout << "    parents:";
            for (const BaseClass* p = t->VpiParent(); p && guard < 8;
                 p = (const BaseClass*)p->VpiParent(), guard++)
                std::cout << " < " << ident(p);
            std::cout << "\n";
        }
        return 0;
    }
    // And the whole lot at once.
    if (only.empty()) {
        std::vector<std::pair<typespec*, const instance*>> saved;
        for (auto& [ty, v] : byType)
            for (typespec* t : v) {
                saved.push_back({t, t->Instance()});
                t->Instance(nullptr);
            }
        report("null EVERY typespec.vpiInstance", da, db);
        for (auto& [t, i] : saved) t->Instance(const_cast<instance*>(i));
        report("RESTORED (must equal BASELINE)", da, db);
    }
    return 0;
}
