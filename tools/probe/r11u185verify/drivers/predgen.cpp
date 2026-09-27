// predgen.cpp <db.uhdm>...: the prediction census of § genericAfterTypedIfacePortTyped185v, read from HEAD (law.bin)
// databases: a port list (module_inst / program / interface_inst Ports, definition or elaborated) in which a GENERIC
// port (its vpiTypedef (the Typespec member) an unsupported_typespec, our generic-port form) follows, through generic ports only, a port
// typed by an interface_typespec.  Such a port is the one the refinement takes out of the generic legs (an
// over-approximation: the legs need a named connection).  Prints "<db> <count>" for every database with a hit.
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <iostream>
using namespace UHDM;
static const typespec* tsOf(const port* p) {
  return p && p->Typespec() ? p->Typespec()->Actual_typespec() : nullptr;
}
int main(int argc, char** argv) {
  for (int i = 1; i < argc; i++) {
    Serializer s; auto designs = s.Restore(std::string(argv[i]));
    int hits = 0;
    for (auto& kv : s.AllObjects()) {
      const BaseClass* o = (const BaseClass*)kv.first;
      const VectorOfport* ports = nullptr;
      if (o->UhdmType() == uhdmmodule_inst) ports = ((const module_inst*)o)->Ports();
      else if (o->UhdmType() == uhdmprogram) ports = ((const program*)o)->Ports();
      else if (o->UhdmType() == uhdminterface_inst) ports = ((const interface_inst*)o)->Ports();
      if (!ports) continue;
      for (size_t k = 1; k < ports->size(); k++) {
        auto* t = tsOf((*ports)[k]);
        if (!t || t->UhdmType() != uhdmunsupported_typespec) continue;
        for (size_t j = k; j-- > 0;) {
          auto* q = tsOf((*ports)[j]);
          if (q && q->UhdmType() == uhdmunsupported_typespec) continue;
          if (q && q->UhdmType() == uhdminterface_typespec) hits++;
          break;
        }
      }
    }
    if (hits) std::cout << argv[i] << " " << hits << "\n";
  }
}
