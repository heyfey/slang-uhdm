// r10v77 VERIFIER -- whole-signal census with a JUDGE-FIELDS payload (no span).
// Every Nets/Variables/Array_nets entry of every module_inst, gen_scope,
// interface_inst, program and package; key = owner kind|owner fullname|name.
// Payload = every field the generated Compare of nets/variables reads, plus
// typespec PRESENCE (kind+name).  Span presence is printed as a SEPARATE
// trailing column so it can be scored on its own.  MEASUREMENT ONLY.
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <uhdm/Serializer.h>
#include <cstdio>
#include <string>
#include <vector>
using namespace UHDM;

static std::string tsOf(const ref_typespec* rt) {
  if (!rt) return "TS=none";
  const typespec* t = rt->Actual_typespec();
  if (!t) return "TS=nullactual";
  std::string n(t->VpiName());
  return "TS=" + std::string(UhdmName(t->UhdmType())) + "/" +
         (n.empty() ? std::string("<anon>") : n);
}
static std::string spanOf(const BaseClass* b) {
  char buf[64];
  snprintf(buf, sizeof buf, "SPAN=%s:%u",
           std::string(b->VpiFile()).empty() ? "-" : "f", b->VpiLineNo());
  return buf;
}
int main(int argc, char** argv) {
  if (argc < 2) { fprintf(stderr, "usage: v77sig <db>\n"); return 2; }
  Serializer s;
  if (s.Restore(std::string(argv[1])).empty()) { fprintf(stderr, "EMPTY\n"); return 3; }
  for (const auto& [obj, id] : s.AllObjects()) {
    std::string owner, ok;
    const std::vector<net*>* nets = nullptr;
    const std::vector<variables*>* vars = nullptr;
    const std::vector<array_net*>* anets = nullptr;
    if (const module_inst* m = any_cast<const module_inst*>(obj)) {
      owner = m->VpiFullName(); ok = "module_inst";
      nets = m->Nets(); vars = m->Variables(); anets = m->Array_nets();
    } else if (const gen_scope* g = any_cast<const gen_scope*>(obj)) {
      owner = g->VpiFullName(); ok = "gen_scope";
      nets = g->Nets(); vars = g->Variables(); anets = g->Array_nets();
    } else if (const interface_inst* i = any_cast<const interface_inst*>(obj)) {
      owner = i->VpiFullName(); ok = "interface_inst";
      nets = i->Nets(); vars = i->Variables(); anets = i->Array_nets();
    } else if (const program* p = any_cast<const program*>(obj)) {
      owner = p->VpiFullName(); ok = "program";
      nets = p->Nets(); vars = p->Variables(); anets = p->Array_nets();
    } else if (const package* pk = any_cast<const package*>(obj)) {
      owner = pk->VpiFullName(); ok = "package";
      vars = pk->Variables();
    } else continue;
    if (nets) for (auto* n : *nets)
      printf("%s|%s|%s|NET|%s|sg=%d nt=%d rnt=%d sc=%d vec=%d am=%d cs=%d exp=%d impl=%d nda=%d sum=%d %s|%s\n",
             ok.c_str(), owner.c_str(), std::string(n->VpiName()).c_str(),
             UhdmName(n->UhdmType()).data(), n->VpiSigned(), n->VpiNetType(),
             n->VpiResolvedNetType(), n->VpiScalar(), n->VpiVector(),
             n->VpiArrayMember(), n->VpiConstantSelect(), n->VpiExpanded(),
             n->VpiImplicitDecl(), n->VpiNetDeclAssign(), n->VpiStructUnionMember(),
             tsOf(n->Typespec()).c_str(), spanOf(n).c_str());
    if (vars) for (auto* v : *vars)
      printf("%s|%s|%s|VAR|%s|sg=%d vis=%d sc=%d vec=%d am=%d auto=%d cv=%d sum=%d %s|%s\n",
             ok.c_str(), owner.c_str(), std::string(v->VpiName()).c_str(),
             UhdmName(v->UhdmType()).data(), v->VpiSigned(), v->VpiVisibility(),
             v->VpiScalar(), v->VpiVector(), v->VpiArrayMember(), v->VpiAutomatic(),
             v->VpiConstantVariable(), v->VpiStructUnionMember(),
             tsOf(v->Typespec()).c_str(), spanOf(v).c_str());
    if (anets) for (auto* a : *anets)
      printf("%s|%s|%s|ANET|%s|- %s|%s\n", ok.c_str(), owner.c_str(),
             std::string(a->VpiName()).c_str(), UhdmName(a->UhdmType()).data(),
             tsOf(a->Typespec()).c_str(), spanOf(a).c_str());
  }
  return 0;
}
