// idxpar <db.uhdm>: per hier_path element that is a bit_select / indexed_part_select / method_func_call, print
// the element position (first/mid/last), the index/argument's kind, its vpiParent kind, its stored-or-computed
// full name, and the hier_path's top-level container kind.  Measurement only (r11u178).
#include <uhdm/Serializer.h>
#include <uhdm/uhdm.h>
#include <iostream>
using namespace UHDM;
static std::string nm(const BaseClass* o) { return o ? std::string(UhdmName(o->UhdmType())) : std::string("null"); }
int main(int argc, char** argv) {
  for (int ai = 1; ai < argc; ai++) {
    Serializer s; s.Restore(std::string(argv[ai]));
    for (auto& kv : s.AllObjects()) {
      auto* o = kv.first; if (!o || o->UhdmType() != uhdmhier_path) continue;
      auto* hp = (const hier_path*)o; auto* pe = hp->Path_elems(); if (!pe) continue;
      const BaseClass* top = hp; while (top->VpiParent() && top->VpiParent()->UhdmType() != uhdmdesign) top = top->VpiParent();
      const BaseClass* sc = hp->VpiParent(); while (sc && sc->UhdmType() != uhdmfunction && sc->UhdmType() != uhdmtask && sc->UhdmType() != uhdmmodule_inst && sc->UhdmType() != uhdmgen_scope && sc->UhdmType() != uhdmpackage && sc->UhdmType() != uhdmclass_defn) sc = sc->VpiParent();
      for (size_t i = 0; i < pe->size(); i++) {
        auto* e = (*pe)[i]; const any* ix = nullptr;
        if (e->UhdmType() == uhdmbit_select) ix = ((const bit_select*)e)->VpiIndex();
        if (!ix) continue;
        const char* pos = i + 1 == pe->size() ? "last" : (i == 0 ? "first" : "mid");
        std::string fn; if (ix->UhdmType() == uhdmref_obj) fn = std::string(((const ref_obj*)ix)->VpiFullName());
        std::cout << hp->VpiName() << " " << pos << " idx=" << nm(ix) << " par=" << nm(ix->VpiParent())
                  << (ix->VpiParent() == e ? "(elem)" : ix->VpiParent() == hp ? "(hp)" : "(other)")
                  << " scope=" << nm(sc) << ":" << (sc ? sc->VpiName() : "") << " top=" << nm(top) << ":" << top->VpiName()
                  << " line=" << ix->VpiLineNo() << " fn=" << fn << "\n";
      }
    }
  }
}
