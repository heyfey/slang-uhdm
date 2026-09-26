// carhs.cpp <db.uhdm>: every cont_assign of every module (definition listing, then the elaborated tree, generate
// scopes included) with the serializer id of its Lhs and Rhs and the Rhs constant's value and parent id, to see which
// objects the cont_assigns share (r11u182; after r11u171repro/drivers/carhs.cpp).
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <iostream>
using namespace UHDM;
static void cas(const std::string& tag, const VectorOfcont_assign* v) {
  if (!v) return;
  for (auto* c : *v) {
    auto* r = c->Rhs();
    std::cout << tag << " ca#" << c->UhdmId() << " " << c->VpiLineNo() << ":" << c->VpiColumnNo() << " rhs#" << (r ? r->UhdmId() : 0)
              << "(" << (r ? UhdmName(r->UhdmType()) : "-");
    if (r && r->UhdmType() == uhdmconstant) std::cout << " " << ((const constant*)r)->VpiValue() << " parent#" << (r->VpiParent() ? r->VpiParent()->UhdmId() : 0)
              << " at " << r->VpiLineNo() << ":" << r->VpiColumnNo() << "-" << r->VpiEndLineNo() << ":" << r->VpiEndColumnNo();
    std::cout << ")\n";
  }
}
static void gs(const std::string& path, const VectorOfgen_scope_array* v);
static void walk(const module_inst* m, const std::string& path) {
  cas("ELAB " + path, m->Cont_assigns());
  if (m->Modules()) for (auto* c : *m->Modules()) walk(c, path + "." + std::string(c->VpiName()));
  gs(path, m->Gen_scope_arrays());
}
static void gs(const std::string& path, const VectorOfgen_scope_array* v) {
  if (!v) return;
  for (auto* ga : *v) if (ga->Gen_scopes()) for (auto* g : *ga->Gen_scopes()) {
    std::string p = path + "." + std::string(ga->VpiName());
    cas("ELAB " + p, g->Cont_assigns());
    if (g->Modules()) for (auto* c : *g->Modules()) walk(c, p + "." + std::string(c->VpiName()));
    gs(p, g->Gen_scope_arrays());
  }
}
int main(int argc, char** argv) {
  Serializer s; auto designs = s.Restore(std::string(argv[1]));
  for (auto h : designs) {
    design* d = UhdmDesignFromVpiHandle(h);
    if (d->AllModules()) for (auto* m : *d->AllModules()) { cas("DEF " + std::string(m->VpiName()), ((const module_inst*)m)->Cont_assigns()); gs("DEF " + std::string(m->VpiName()), ((const module_inst*)m)->Gen_scope_arrays()); }
    if (d->TopModules()) for (auto* m : *d->TopModules()) walk(m, std::string(m->VpiName()));
  }
}
