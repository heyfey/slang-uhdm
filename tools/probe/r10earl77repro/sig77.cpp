// r10earl77 — WHOLE-SIGNAL census: every Nets / Variables / Array_nets entry of
// every module_inst (definition views included), keyed by the owner's
// vpiFullName and the signal's name, with the CONTAINER and the object KIND as
// the payload.  The head this pass clears is a `module_inst` VECTOR SIZE
// mismatch on Nets/Variables, so a port-only census is blind to a body signal
// that moves; this one is not.  MEASUREMENT ONLY.
//   usage: sig77 <db.uhdm>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <uhdm/Serializer.h>
#include <cstdio>
#include <string>
using namespace UHDM;
int main(int argc, char** argv) {
  if (argc < 2) { fprintf(stderr, "usage: sig77 <db>\n"); return 2; }
  Serializer s;
  if (s.Restore(std::string(argv[1])).empty()) { fprintf(stderr, "EMPTY\n"); return 3; }
  for (const auto& [obj, id] : s.AllObjects()) {
    std::string owner, ownerKind;
    const std::vector<net*>* nets = nullptr;
    const std::vector<variables*>* vars = nullptr;
    const std::vector<array_net*>* anets = nullptr;
    if (const module_inst* m = any_cast<const module_inst*>(obj)) {
      owner = m->VpiFullName(); ownerKind = "module_inst";
      nets = m->Nets(); vars = m->Variables(); anets = m->Array_nets();
    } else if (const gen_scope* g = any_cast<const gen_scope*>(obj)) {
      owner = g->VpiFullName(); ownerKind = "gen_scope";
      nets = g->Nets(); vars = g->Variables(); anets = g->Array_nets();
    } else if (const interface_inst* i = any_cast<const interface_inst*>(obj)) {
      owner = i->VpiFullName(); ownerKind = "interface_inst";
      nets = i->Nets(); vars = i->Variables(); anets = i->Array_nets();
    } else continue;
    if (nets) for (auto* n : *nets)
      printf("%s|%s|%s|NET|%s\n", ownerKind.c_str(), owner.c_str(),
             std::string(n->VpiName()).c_str(), UhdmName(n->UhdmType()).data());
    if (vars) for (auto* v : *vars)
      printf("%s|%s|%s|VAR|%s\n", ownerKind.c_str(), owner.c_str(),
             std::string(v->VpiName()).c_str(), UhdmName(v->UhdmType()).data());
    if (anets) for (auto* a : *anets)
      printf("%s|%s|%s|ANET|%s\n", ownerKind.c_str(), owner.c_str(),
             std::string(a->VpiName()).c_str(), UhdmName(a->UhdmType()).data());
  }
  return 0;
}
