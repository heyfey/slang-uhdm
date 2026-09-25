// carhs_db <db.uhdm> [scope-substring]: for every ELABORATED instance (uhdmtopModules, recursive through
// module instances and gen scopes) whose full name contains the substring, print each cont_assign's Rhs kind,
// name, span and value, and whether the cont_assign object is also listed by the instance's definition
// (uhdmallModules) -- i.e. the definition's own object shared into the elaborated listing.
#include <uhdm/uhdm.h>
#include <uhdm/Serializer.h>
#include <cstdio>
#include <set>
#include <string>
using namespace UHDM;
static std::set<const any*> defCas;
static std::string sub;
static void pr(const std::string& scope, const VectorOfcont_assign* v) {
  if (!v) return;
  if (!sub.empty() && scope.find(sub) == std::string::npos) return;
  for (auto* ca : *v) {
    const any* r = ca->Rhs();
    std::string k = r ? UhdmName(r->UhdmType()) : "null";
    std::string nm = r ? std::string(r->VpiName()) : "";
    std::string val;
    if (r && r->UhdmType() == uhdmconstant) val = std::string(((const constant*)r)->VpiValue());
    printf("%s\tca %d:%d\trhs=%s %s %d:%d-%d:%d %s\tshared_with_def=%d\n", scope.c_str(), ca->VpiLineNo(),
           ca->VpiColumnNo(), k.c_str(), nm.c_str(), r ? r->VpiLineNo() : 0, r ? r->VpiColumnNo() : 0,
           r ? r->VpiEndLineNo() : 0, r ? r->VpiEndColumnNo() : 0, val.c_str(), (int)defCas.count(ca));
  }
}
static void gs(const std::string& scope, const gen_scope* g);
static void inst(const module_inst* m) {
  std::string sc(m->VpiFullName());
  pr(sc, m->Cont_assigns());
  if (m->Modules()) for (auto* c : *m->Modules()) inst(c);
  if (m->Gen_scope_arrays())
    for (auto* a : *m->Gen_scope_arrays())
      if (a->Gen_scopes()) for (auto* g : *a->Gen_scopes()) gs(sc + "." + std::string(a->VpiName()), g);
}
static void gs(const std::string& scope, const gen_scope* g) {
  pr(scope, g->Cont_assigns());
  if (g->Modules()) for (auto* c : *g->Modules()) inst(c);
  if (g->Gen_scope_arrays())
    for (auto* a : *g->Gen_scope_arrays())
      if (a->Gen_scopes()) for (auto* g2 : *a->Gen_scopes()) gs(scope + "." + std::string(a->VpiName()), g2);
}
int main(int argc, char** argv) {
  if (argc < 2) return 2;
  if (argc > 2) sub = argv[2];
  Serializer s;
  auto designs = s.Restore(std::string(argv[1]));
  for (vpiHandle h : designs) {
    const design* d = (const design*)((const uhdm_handle*)h)->object;
    if (d->AllModules()) for (auto* m : *d->AllModules()) if (m->Cont_assigns()) for (auto* c : *m->Cont_assigns()) defCas.insert(c);
    if (d->TopModules()) for (auto* m : *d->TopModules()) inst(m);
  }
  return 0;
}
