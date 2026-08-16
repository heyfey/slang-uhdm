// r10sd7 — THE SAME SUBTREE, ON THE PACKAGE'S OWN LISTING.
//
// `ct7sub` finds the head: the `Index_typespec` of the class-listing COPY's
// `array_typespec` — `string_typespec@328:44-328:50`, golden `<null>`, ours
// `TOP:uvm_pkg`.
//
// That measurement alone does NOT decide the law, and the difference between the
// two readings is two different patches:
//
//   (a) "an associative array's index typespec never carries an instance"
//       -> the fix is in the array emitter, and it would apply to the PACKAGE's
//          own listing too;
//   (b) "the class-listing COPY owns its whole typespec subtree, unstamped"
//       -> the fix is in the import copier, and the package's own listing must
//          KEEP its stamp.
//
// The package's own listing is what tells them apart, so it is read here before
// any code is written.  Same shape as sd5/sd6's decision: the copy, not the kind.
//
// GUARD: a package or variable that matches nothing is a hard error.
//
// build: g++ -O2 -std=c++17 ct7pkgsub.cpp -I ~/.local/include \
//          -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct7pkgsub
// usage: ct7pkgsub <db.uhdm> <var-name>
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
    std::cout << pad << lbl << " " << ident(t) << "  inst=" << view(t->Instance())
              << "  ptr=" << (const void*)t << "\n";
    if (d > 4) return;
    if (t->UhdmType() == uhdmarray_typespec) {
        auto* a = (const array_typespec*)t;
        rts("index:", a->Index_typespec(), d + 1);
        rts("elem :", a->Elem_typespec(), d + 1);
    }
}

int main(int argc, char** argv) {
    if (argc < 3) { std::cerr << "usage: ct7pkgsub <db> <varname>\n"; return 2; }
    std::string want = argv[2];
    Serializer s;
    auto h = s.Restore(std::filesystem::path(argv[1]));
    if (h.empty()) { std::cerr << "RESTORE FAILED\n"; return 3; }
    auto* d = (design*)((uhdm_handle*)h[0])->object;
    if (auto* v = d->AllPackages()) for (auto* p : *v) g_all.insert(p);
    if (auto* v = d->TopPackages()) for (auto* p : *v) g_top.insert(p);
    int n = 0;
    auto doPkg = [&](package* p, const char* tag) {
        if (!p->Variables()) return;
        for (auto* v : *p->Variables()) {
            if (!v || v->VpiName() != want) continue;
            n++;
            std::cout << "== [" << tag << "] package " << p->VpiName() << " :: " << ident(v)
                      << "  varInst=" << view(v->Instance()) << "\n";
            rts("ts   :", v->Typespec(), 1);
        }
    };
    if (auto* v = d->AllPackages()) for (auto* p : *v) doPkg(p, "ALL");
    if (auto* v = d->TopPackages()) for (auto* p : *v) doPkg(p, "TOP");
    if (n == 0) { std::cerr << "REFUSING TO REPORT: no package variable " << want << "\n"; return 5; }
    return 0;
}
