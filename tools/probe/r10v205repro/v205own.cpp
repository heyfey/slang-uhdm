// r10v205 — THE OWNER-MASK AUDIT (adversarial verification of r10uvm205).
//
// MEASUREMENT ONLY; `~/git-repos/UHDM/build/bin/uhdm-cmp` is the sole judge.
//
// § cloneArrayElemBareTdAlias205's exclusivity guard marks a ref "some OTHER
// declaration reaches it" only from a `variables`/`io_decl` whose VpiParent
// climb reaches a `function`/`task` BEFORE it reaches a `class_defn`,
// `package`, `module_inst` or `design`.  Three populations therefore escape
// the guard entirely and can never set bit 2:
//
//   * a CLASS PROPERTY               (the climb stops at `class_defn`)
//   * a PACKAGE- or MODULE-level var (the climb stops at `package`/`module_inst`)
//   * an UNPARENTED declaration      (the climb runs off the end)
//
// If any element `ref_typespec` a clone body's declaration reaches is ALSO
// reached from one of those three, the law re-points a link a non-clone cell
// owns and that cell moves with it.  The pass's own census cannot see this: its
// `subrOf` climb `continue`s on exactly the same three populations, so the
// blind spot is SHARED between the law and the instrument that scored it.
//
// This probe re-implements `walk205` verbatim, adds the three escaped
// populations as a THIRD bit, and reports every ref the law would move
// (mask == 1 under the law's own marking) that an escaped declaration also
// reaches.  A nonzero ESCAPED_SHARED count is a live regression path.
//
// build: g++ -O2 -std=c++17 v205own.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o v205own
// usage: v205own <db.uhdm> [--list]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <cstdio>
#include <cstring>
#include <functional>
#include <map>
#include <string>

using namespace UHDM;

static const BaseClass* declTf(const BaseClass* o, const char** why) {
    for (const BaseClass* p = o->VpiParent(); p; p = p->VpiParent()) {
        const auto k = p->UhdmType();
        if (k == uhdmfunction || k == uhdmtask) { *why = "subr"; return p; }
        if (k == uhdmclass_defn)  { *why = "class_defn";  return nullptr; }
        if (k == uhdmpackage)     { *why = "package";     return nullptr; }
        if (k == uhdmmodule_inst) { *why = "module_inst"; return nullptr; }
        if (k == uhdmdesign)      { *why = "design";      return nullptr; }
    }
    *why = "unparented";
    return nullptr;
}

int main(int argc, char** argv) {
    if (argc < 2) { fprintf(stderr, "usage: v205own <db.uhdm> [--list]\n"); return 2; }
    bool list = argc > 2 && !strcmp(argv[2], "--list");
    Serializer s;
    if (s.Restore(std::string(argv[1])).empty()) { printf("RESTORE_FAIL\n"); return 3; }

    // bit 1 = reached from a declaration INSIDE a subroutine (the law's bit 1
    //         and bit 2 both live here; the law's clone test is not needed for
    //         this audit, only "the guard can see it")
    // bit 4 = reached from an ESCAPED declaration (class property / package- or
    //         module-level variable / unparented)
    std::map<const ref_typespec*, int> mask;
    std::map<const ref_typespec*, std::string> firstEscaped;
    std::map<std::string, int> escapedKinds;

    std::function<void(const ref_typespec*, int, int, bool, const std::string&)> walk =
        [&](const ref_typespec* rt, int bit, int budget, bool below,
            const std::string& owner) {
            if (!rt || budget <= 0) return;
            if (below) {
                mask[rt] |= bit;
                if (bit == 4 && !firstEscaped.count(rt)) firstEscaped[rt] = owner;
            }
            const typespec* at = rt->Actual_typespec();
            if (!at) return;
            if (at->UhdmType() == uhdmarray_typespec) {
                auto* a = (const array_typespec*)at;
                walk(a->Elem_typespec(),  bit, budget - 1, true, owner);
                walk(a->Index_typespec(), bit, budget - 1, true, owner);
            } else if (at->UhdmType() == uhdmpacked_array_typespec) {
                auto* a = (const packed_array_typespec*)at;
                walk(a->Elem_typespec(), bit, budget - 1, true, owner);
            }
        };

    int nDecl = 0, nSubr = 0, nEscaped = 0;
    for (auto& kv : s.AllObjects()) {
        const BaseClass* o = kv.first;
        if (!o) continue;
        const ref_typespec* rt = nullptr;
        if (auto* v = any_cast<const variables*>(o))      rt = v->Typespec();
        else if (auto* io = any_cast<const io_decl*>(o))  rt = io->Typespec();
        if (!rt) continue;
        nDecl++;
        const char* why = "";
        const BaseClass* tf = declTf(o, &why);
        if (tf) { nSubr++; walk(rt, 1, 8, false, ""); }
        else {
            nEscaped++;
            escapedKinds[why]++;
            char b[512];
            snprintf(b, sizeof b, "%s %s@%u:%u", why,
                     std::string(o->VpiName()).c_str(), o->VpiLineNo(),
                     (unsigned)o->VpiColumnNo());
            walk(rt, 4, 8, false, std::string(b));
        }
    }
    int shared = 0, escapedOnly = 0, subrOnly = 0;
    for (auto& [rt, m] : mask) {
        if ((m & 1) && (m & 4)) {
            shared++;
            if (list) {
                const typespec* at = rt->Actual_typespec();
                printf("ESCAPED_SHARED ts=%s owner=%s\n",
                       at ? std::string(at->VpiName()).c_str() : "-",
                       firstEscaped[rt].c_str());
            }
        } else if (m & 4) escapedOnly++;
        else subrOnly++;
    }
    printf("DECLS %d  in-subroutine %d  ESCAPED %d (", nDecl, nSubr, nEscaped);
    for (auto& [k, n] : escapedKinds) printf("%s=%d ", k.c_str(), n);
    printf(")\n");
    printf("BELOW-ARRAY REFS %zu  subr-only %d  escaped-only %d  "
           "ESCAPED_SHARED %d\n", mask.size(), subrOnly, escapedOnly, shared);
    return 0;
}
