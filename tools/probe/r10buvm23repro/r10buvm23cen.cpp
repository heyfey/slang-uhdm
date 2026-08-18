// r10buvm23 — THE HIER_PATH CENSUS.  MEASUREMENT ONLY; nothing here is an
// acceptance judge (uhdm-cmp and scripts/verify_golden.py are).
//
// LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
//
// FAMILY `HP` — one row per `hier_path` object, carrying
//   * VIEW    — the root listing the object is reached from (ELABPKG / DEFPKG /
//               DEFCLASS / TOPMOD / DEFMOD / …), buvm17/21/22's classifier.
//   * OWNER   — the nearest enclosing function/task fullname, else the nearest
//               named ancestor (class_defn / module / package).
//   * LOC     — line:col of the object's START.  Our expression nodes carry an
//               EMPTY VpiFile (buvm16's trap), so the key is line:col + shape,
//               never the file.
//   * NAME    — VpiName, which `hier_path::Compare` reads (through
//               BaseClass::Compare, BEFORE Path_elems — see the README's head
//               decode).
//   * NEL     — Path_elems size, the field the VECTOR SafeCompare overload
//               names both containers on.
//   * ELEMS   — per element `kind:VpiName:VpiFullName[:idx=<kind>]`, so a
//               2-vs-3 split shows WHICH element differs and an index's own
//               object kind (the decompileHelper dispatch's discriminator) is
//               visible.
//
// FAMILY `BOGUS` — every object whose VpiName contains `[`, `]`, `(` or `)`.
// A name with a bracket in it is a fossil of a TEXT split (this pass's defect
// family); a `bit_select`'s vpiFullName legitimately carries brackets and is
// NOT part of this family (only VpiName is tested).
//
// usage: r10buvm23cen <file.uhdm> [tag]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <iostream>
#include <map>
#include <string>
#include <vector>
using namespace UHDM;

static std::string nm(const any* t) { return t ? std::string(t->VpiName()) : "-"; }
static std::string fnm(const any* t) {
    if (!t) return "-";
    if (const scope* sc = any_cast<const scope*>(t)) return std::string(sc->VpiFullName());
    if (const ref_obj* r = any_cast<const ref_obj*>(t)) return std::string(r->VpiFullName());
    if (const bit_select* b = any_cast<const bit_select*>(t)) return std::string(b->VpiFullName());
    if (const var_select* v = any_cast<const var_select*>(t)) return std::string(v->VpiFullName());
    if (const hier_path* h = any_cast<const hier_path*>(t)) return std::string(h->VpiFullName());
    if (const part_select* q = any_cast<const part_select*>(t)) return std::string(q->VpiFullName());
    if (const indexed_part_select* i = any_cast<const indexed_part_select*>(t)) return std::string(i->VpiFullName());
    if (const tf_call* c = any_cast<const tf_call*>(t)) return std::string(c->VpiName());
    return std::string(t->VpiName());
}
static std::string kd(const any* t) { return t ? std::string(UhdmName(t->UhdmType())) : "NULL"; }
static std::string loc(const any* o) {
    return o ? std::to_string(o->VpiLineNo()) + ":" + std::to_string(o->VpiColumnNo()) : "-";
}
static std::string esc(std::string s) {
    for (auto& c : s) if (c == '\t' || c == '\n') c = ' ';
    return s;
}

// The index object of a path element, when the element kind has one.
static const any* elemIdx(const any* e) {
    if (!e) return nullptr;
    if (e->UhdmType() == uhdmbit_select) return ((const bit_select*)e)->VpiIndex();
    return nullptr;
}
static std::string elemIdxDesc(const any* e) {
    if (!e) return "";
    if (e->UhdmType() == uhdmvar_select) {
        const var_select* vs = (const var_select*)e;
        std::string r = ":idx=";
        if (auto* v = vs->Exprs()) {
            for (auto* x : *v) r += kd(x) + ",";
        } else r += "-";
        return r;
    }
    const any* i = elemIdx(e);
    if (!i) return "";
    return ":idx=" + kd(i) + "(" + esc(nm(i)) + ")";
}

int main(int argc, char** argv) {
    if (argc < 2) { std::cerr << "usage: r10buvm23cen <file.uhdm> [tag]\n"; return 2; }
    std::string tag = argc > 2 ? argv[2] : "T";
    Serializer s;
    if (s.Restore(std::string(argv[1])).empty()) { std::cout << "RESTORE_FAIL " << tag << "\n"; return 3; }

    std::map<const any*, std::string> rootView;
    for (auto& kv : s.AllObjects()) {
        const any* o = kv.first;
        if (!o || o->UhdmType() != uhdmdesign) continue;
        const design* d = (const design*)o;
        if (auto* v = d->TopPackages()) for (auto* p : *v) rootView.emplace(p, "ELABPKG");
        if (auto* v = d->TopModules()) for (auto* p : *v) rootView.emplace(p, "TOPMOD");
        if (auto* v = d->AllPackages()) for (auto* p : *v) rootView.emplace(p, "DEFPKG");
        if (auto* v = d->AllModules()) for (auto* p : *v) rootView.emplace(p, "DEFMOD");
        if (auto* v = d->AllClasses()) for (auto* p : *v) rootView.emplace(p, "DEFCLASS");
        if (auto* v = d->AllPrograms()) for (auto* p : *v) rootView.emplace(p, "DEFPROG");
        if (auto* v = d->AllInterfaces()) for (auto* p : *v) rootView.emplace(p, "DEFIFACE");
    }

    long hp = 0, bogus = 0;
    for (auto& kv : s.AllObjects()) {
        const any* o = kv.first;
        if (!o) continue;

        // --- FAMILY BOGUS -------------------------------------------------
        {
            std::string n(o->VpiName());
            if (n.find('[') != std::string::npos || n.find(']') != std::string::npos ||
                n.find('(') != std::string::npos || n.find(')') != std::string::npos) {
                const any* p = o->VpiParent();
                std::cout << tag << "\tBOGUS\t" << kd(o) << "\t" << esc(n) << "\t"
                          << loc(o) << "\tpar=" << kd(p) << "\n";
                bogus++;
            }
        }

        if (o->UhdmType() != uhdmhier_path) continue;
        const hier_path* h = (const hier_path*)o;

        // view + owner
        const any* owner = nullptr;
        const any* root = nullptr;
        const any* p = o->VpiParent();
        int d = 0;
        while (p && d++ < 200) {
            UHDM_OBJECT_TYPE t = p->UhdmType();
            if (!owner && (t == uhdmfunction || t == uhdmtask)) owner = p;
            auto it = rootView.find(p);
            if (it != rootView.end()) { root = p; break; }
            if (t == uhdmdesign) break;
            if (!owner && (t == uhdmclass_defn || t == uhdmmodule_inst ||
                           t == uhdmpackage))
                owner = p;
            p = p->VpiParent();
        }
        std::string view = root ? rootView[root] : "OTHER";
        std::string own = owner ? fnm(owner) : std::string("-");
        if (own.empty()) own = "-";

        std::string elems;
        int nel = 0;
        if (auto* v = h->Path_elems()) {
            nel = (int)v->size();
            for (auto* e : *v) {
                if (!elems.empty()) elems += " | ";
                elems += kd(e) + ":" + esc(nm(e)) + ":" + esc(fnm(e)) + elemIdxDesc(e);
            }
        }
        std::cout << tag << "\tHP\t" << view << "\t" << own << "\t" << loc(o)
                  << "\t" << esc(std::string(h->VpiName())) << "\tnel=" << nel
                  << "\tpar=" << kd(o->VpiParent()) << "\t" << elems
                  << "\troot=" << kd(h->Root_value()) << "\n";
        hp++;
    }
    std::cerr << "ROWS " << tag << " HP " << hp << " BOGUS " << bogus << "\n";
    return 0;
}
