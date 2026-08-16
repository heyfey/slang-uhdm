// r10sd7 — THE SUBTREE READ.  A named variable's whole typespec subtree, with
// every `vpiInstance` resolved to a VIEW, on one side.  Run on both and diff.
//
// This is where the localization lands.  `ct4scan`'s `visited`-pool suppression
// scan returns 21 singleton killers; they are ancestors, not the owner (sd4 R6),
// but the DEEPEST of them on the real path is
// `array_var(uvm_random_seed_table_lookup)` inside `class_defn(adpcm_seq_item)`
// — and suppressing it kills the head, so the failing pair is AT OR BELOW it.
//
// `ct7own` already proved the array_var's OWN actual typespec agrees
// (`array_typespec@0:0`, `Instance` null on both sides), so the failure is
// deeper: `array_typespec::Compare` goes on to compare `Index_typespec` and
// `Elem_typespec`, each a `ref_typespec` onto a further typespec that has an
// `Instance` of its own.  That is the level this tool prints.
//
// GUARD: a variable that matches nothing is a hard error.
//
// build: g++ -O2 -std=c++17 ct7sub.cpp -I ~/.local/include \
//          -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct7sub
// usage: ct7sub <db.uhdm> <var-name>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <set>
#include <string>

using namespace UHDM;

static std::set<const BaseClass*> g_all, g_top;
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
static std::string view(const instance* i) {
    if (!i) return "<null>";
    std::string nm(i->VpiName());
    if (g_top.count(i)) return "TOP:" + nm;
    if (g_all.count(i)) return "ALL:" + nm;
    return "OTHER:" + nm;
}
static void ts(const std::string& lbl, const typespec* t, int d);
static void rts(const std::string& lbl, const ref_typespec* r, int d) {
    if (!r) { std::cout << std::string(d * 2, ' ') << lbl << " ref=<null>\n"; return; }
    ts(lbl, r->Actual_typespec(), d);
}
static void ts(const std::string& lbl, const typespec* t, int d) {
    std::string pad(d * 2, ' ');
    if (!t) { std::cout << pad << lbl << " <null>\n"; return; }
    std::cout << pad << lbl << " " << ident(t) << "  inst=" << view(t->Instance()) << "  ptr=" << (const void*)t << "\n";
    if (d > 4) return;
    if (t->UhdmType() == uhdmarray_typespec) {
        auto* a = (const array_typespec*)t;
        rts("index:", a->Index_typespec(), d + 1);
        rts("elem :", a->Elem_typespec(), d + 1);
    } else if (t->UhdmType() == uhdmpacked_array_typespec) {
        auto* a = (const packed_array_typespec*)t;
        rts("elem :", a->Elem_typespec(), d + 1);
    }
}

int main(int argc, char** argv) {
    if (argc < 3) { std::cerr << "usage: ct7sub <db> <varname>\n"; return 2; }
    std::string want = argv[2];
    Serializer s;
    auto h = s.Restore(std::filesystem::path(argv[1]));
    if (h.empty()) { std::cerr << "RESTORE FAILED\n"; return 3; }
    auto* d = (design*)((uhdm_handle*)h[0])->object;
    if (auto* v = d->AllPackages()) for (auto* p : *v) g_all.insert(p);
    if (auto* v = d->TopPackages()) for (auto* p : *v) g_top.insert(p);
    int n = 0;
    for (const auto& [obj, id] : s.AllObjects()) {
        if (!obj || obj->UhdmType() != uhdmclass_defn) continue;
        auto* cd = (class_defn*)obj;
        if (!cd->Variables()) continue;
        for (auto* v : *cd->Variables()) {
            if (!v || v->VpiName() != want) continue;
            n++;
            std::cout << "== " << cd->VpiFullName() << "@" << span(cd) << " :: "
                      << ident(v) << "  varInst=" << view(v->Instance()) << "\n";
            rts("ts   :", v->Typespec(), 1);
        }
    }
    if (n == 0) { std::cerr << "REFUSING TO REPORT: no variable named " << want << "\n"; return 5; }
    return 0;
}
