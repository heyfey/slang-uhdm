// r10v77 VERIFIER -- PORT census with the judge fields ports::Compare reads,
// plus the backing container entry.  Key = def|port|dir|instance (identity);
// payload = everything the law can move.  No span in the payload (printed as a
// separate trailing column).  MEASUREMENT ONLY.
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <uhdm/Serializer.h>
#include <cstdio>
#include <map>
#include <string>
using namespace UHDM;
static const char* dirName(int d) {
  switch (d) { case vpiInput: return "IN"; case vpiOutput: return "OUT";
    case vpiInout: return "INOUT"; case vpiMixedIO: return "MIXED";
    case vpiNoDirection: return "NODIR"; default: return "?"; }
}
static std::string tsDesc(const ref_typespec* rt) {
  if (!rt) return "none";
  const typespec* t = rt->Actual_typespec();
  if (!t) return "nullactual";
  std::string n(t->VpiName());
  return std::string(UhdmName(t->UhdmType())) + "/" + (n.empty() ? std::string("<anon>") : n);
}
static std::string conn(const any* l) {
  if (!l) return "<none>";
  std::string r(UhdmName(l->UhdmType()));
  if (l->UhdmType() == uhdmref_obj) {
    const any* a = ((const ref_obj*)l)->Actual_group();
    r += "->" + (a ? std::string(UhdmName(a->UhdmType())) : std::string("<null>"));
  }
  return r;
}
int main(int argc, char** argv) {
  if (argc < 2) return 2;
  Serializer s;
  if (s.Restore(std::string(argv[1])).empty()) { fprintf(stderr, "EMPTY\n"); return 3; }
  for (const auto& [obj, id] : s.AllObjects()) {
    std::string def, full;
    const std::vector<port*>* ports = nullptr;
    std::map<std::string, std::string> byName;
    if (const module_inst* m = any_cast<const module_inst*>(obj)) {
      def = m->VpiDefName(); full = m->VpiFullName(); ports = m->Ports();
      if (m->Nets()) for (auto* n : *m->Nets()) byName[std::string(n->VpiName())] = "NET:" + std::string(UhdmName(n->UhdmType()));
      if (m->Variables()) for (auto* v : *m->Variables()) byName[std::string(v->VpiName())] = "VAR:" + std::string(UhdmName(v->UhdmType()));
      if (m->Array_nets()) for (auto* a : *m->Array_nets()) byName[std::string(a->VpiName())] = "ANET:" + std::string(UhdmName(a->UhdmType()));
    } else if (const interface_inst* i = any_cast<const interface_inst*>(obj)) {
      def = i->VpiDefName(); full = i->VpiFullName(); ports = i->Ports();
      if (i->Nets()) for (auto* n : *i->Nets()) byName[std::string(n->VpiName())] = "NET:" + std::string(UhdmName(n->UhdmType()));
      if (i->Variables()) for (auto* v : *i->Variables()) byName[std::string(v->VpiName())] = "VAR:" + std::string(UhdmName(v->UhdmType()));
    } else if (const program* p = any_cast<const program*>(obj)) {
      def = p->VpiDefName(); full = p->VpiFullName(); ports = p->Ports();
      if (p->Nets()) for (auto* n : *p->Nets()) byName[std::string(n->VpiName())] = "NET:" + std::string(UhdmName(n->UhdmType()));
      if (p->Variables()) for (auto* v : *p->Variables()) byName[std::string(v->VpiName())] = "VAR:" + std::string(UhdmName(v->UhdmType()));
    } else continue;
    if (!ports) continue;
    for (auto* p : *ports) {
      std::string pn(p->VpiName());
      auto it = byName.find(pn);
      printf("%s|%s|%s|%s|BACK=%s|TS=%s|LOW=%s|HIGH=%s|idx=%d pt=%d sc=%d vec=%d cbn=%d sz=%d en=%s|SPAN=%s:%d\n",
             def.c_str(), pn.c_str(), dirName(p->VpiDirection()), full.c_str(),
             (it == byName.end() ? std::string("<none>") : it->second).c_str(),
             tsDesc(p->Typespec()).c_str(), conn(p->Low_conn()).c_str(),
             conn(p->High_conn()).c_str(), p->VpiPortIndex(), p->VpiPortType(),
             p->VpiScalar(), p->VpiVector(), p->VpiConnByName(), p->VpiSize(),
             std::string(p->VpiExplicitName()).c_str(),
             std::string(p->VpiFile()).empty() ? "-" : "f", p->VpiLineNo());
    }
  }
  return 0;
}
