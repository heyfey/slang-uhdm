// r10sd2 VERIFIER — the mutation §4.4 hypothesis 1 CLAIMS but NO DELIVERED
// INSTRUMENT PERFORMS.
//
// The r10sd2 record states: "'It's the class_defn-valued vpiInstance (§1).'
// Nulling all 428 of them: head byte-identical ... The §1 law is real and is
// NOT the head."  That mutation selects by the VALUE's type (`class_defn`),
// whereas the shipped `ct2mut.cpp` selects by the OWNER's type
// (`bit_typespec`, `class_typespec`, ...).  No file in the delivered probe
// directory mentions `class_defn` outside the two READMEs, so the claim that
// retires the pass's own headline law as "not the head" was not reproducible
// from the delivered instruments.  This tool closes that gap.
//
// It nulls `Instance()` on exactly those objects whose `Instance()` IS a
// `class_defn`, re-runs the whole-design Compare, and restores.  The COUNT of
// mutated slots is printed, so a vacuous run (0 slots nulled -> "no change"
// proves nothing) is visible rather than silent.  A restore control follows,
// and it must reprint the baseline exactly.
//
// build: g++ -O2 -std=c++17 ct2vclsdefn.cpp -I ~/.local/include \
//          -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct2vclsdefn
// usage: ct2vclsdefn <golden.uhdm> <ours.uhdm>          (LHS ALWAYS GOLDEN)
#include <uhdm/uhdm.h>

#include <filesystem>
#include <iostream>
#include <map>
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
        std::cerr << "usage: ct2vclsdefn <golden.uhdm> <ours.uhdm>\n";
        return 2;
    }
    Serializer sa, sb;
    auto ha = sa.Restore(std::filesystem::path(argv[1]));
    auto hb = sb.Restore(std::filesystem::path(argv[2]));
    if (ha.empty() || hb.empty()) { std::cerr << "RESTORE_FAIL\n"; return 3; }
    auto* da = (design*)((uhdm_handle*)ha[0])->object;
    auto* db = (design*)((uhdm_handle*)hb[0])->object;

    report("BASELINE                          ", da, db);

    // Select by the VALUE's type, over every carrier of a singular Instance().
    std::vector<std::pair<typespec*, const instance*>> ts;
    std::vector<std::pair<task_func*, const instance*>> tf;
    std::vector<std::pair<variables*, const instance*>> vr;
    std::map<std::string, int> byName;
    for (const auto& [p, id] : sb.AllObjects()) {
        BaseClass* b = const_cast<BaseClass*>(p);
        const instance* v = nullptr;
        typespec* t = any_cast<typespec*>(b);
        task_func* f = t ? nullptr : any_cast<task_func*>(b);
        variables* w = (t || f) ? nullptr : any_cast<variables*>(b);
        if (t) v = t->Instance();
        else if (f) v = f->Instance();
        else if (w) v = w->Instance();
        else continue;
        if (!v || v->UhdmType() != UHDM_OBJECT_TYPE::uhdmclass_defn) continue;
        byName[std::string(v->VpiName())]++;
        if (t) ts.push_back({t, v});
        else if (f) tf.push_back({f, v});
        else vr.push_back({w, v});
    }
    const size_t n = ts.size() + tf.size() + vr.size();
    std::cout << "class_defn-valued Instance() slots on OUR side: " << n
              << "  (typespec=" << ts.size() << " task_func=" << tf.size()
              << " variables=" << vr.size() << ")  over " << byName.size()
              << " class names\n";
    if (n == 0) {
        std::cout << "REFUSING TO REPORT: 0 slots selected -- any 'no change' "
                     "result would be vacuous\n";
        return 4;
    }
    for (const auto& [k, c] : byName) std::cout << "    " << k << " = " << c << "\n";

    for (auto& [t, v] : ts) t->Instance(nullptr);
    for (auto& [f, v] : tf) f->Instance(nullptr);
    for (auto& [w, v] : vr) w->Instance(nullptr);
    report("NULLED all class_defn-valued      ", da, db);

    for (auto& [t, v] : ts) t->Instance(const_cast<instance*>(v));
    for (auto& [f, v] : tf) f->Instance(const_cast<instance*>(v));
    for (auto& [w, v] : vr) w->Instance(const_cast<instance*>(v));
    report("RESTORED (must equal BASELINE)    ", da, db);
    return 0;
}
