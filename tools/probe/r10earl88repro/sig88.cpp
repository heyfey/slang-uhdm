// r10earl88 — WHOLE-SIGNAL census with the VAR-vs-NET payload.  For every
// module_inst / gen_scope / interface_inst in one .uhdm database, one row per
// Nets / Variables / Array_nets entry: the CONTAINER it lives in, the object
// KIND, the kind+name of its typespec, the kind of its first Element (for a
// packed_array_*), and the direction of the same-named PORT when there is one.
// The head this pass clears is a `module_inst` Nets/Variables VECTOR SIZE
// mismatch, so a port-keyed census is structurally blind to a body signal that
// moves; this one is not, and it is the arbiter.  Carries NO span in the
// payload (earl60/earl77 lesson).  MEASUREMENT ONLY — reads a database and
// dispatches nothing.
//   build: g++ -O2 -std=c++17 sig88.cpp -I ~/.local/include \
//              -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o sig88
//   usage: sig88 <db.uhdm>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <uhdm/Serializer.h>
#include <cstdio>
#include <map>
#include <string>
#include <vector>
using namespace UHDM;

static const char* dirName(int d) {
  switch (d) {
    case vpiInput: return "IN";
    case vpiOutput: return "OUT";
    case vpiInout: return "INOUT";
    case vpiMixedIO: return "MIXED";
    case vpiNoDirection: return "NODIR";
    default: return "-";
  }
}
static std::string tsDesc(const ref_typespec* rt) {
  if (!rt) return "none/-";
  const typespec* t = rt->Actual_typespec();
  if (!t) return "nullactual/-";
  std::string k(UhdmName(t->UhdmType()));
  std::string n(t->VpiName());
  return k + "/" + (n.empty() ? std::string("<anon>") : n);
}
template <class T>
static std::string elemKind(const T* o) {
  if (!o->Elements() || o->Elements()->empty()) return "-";
  return std::string(UhdmName((*o->Elements())[0]->UhdmType()));
}
static void row(const char* ownerKind, const std::string& owner,
                const std::string& name, const char* cont, const any* o,
                const std::map<std::string, int>& portDir) {
  std::string ek = "-", ts = "none/-";
  UHDM_OBJECT_TYPE k = o->UhdmType();
  if (k == uhdmpacked_array_var) {
    const packed_array_var* p = (const packed_array_var*)o;
    ek = elemKind(p); ts = tsDesc(p->Typespec());
  } else if (k == uhdmpacked_array_net) {
    const packed_array_net* p = (const packed_array_net*)o;
    ek = elemKind(p); ts = tsDesc(p->Typespec());
  } else if (const variables* v = any_cast<const variables*>(o)) {
    ts = tsDesc(v->Typespec());
  } else if (const net* n = any_cast<const net*>(o)) {
    ts = tsDesc(n->Typespec());
  } else if (const array_net* a = any_cast<const array_net*>(o)) {
    (void)a;
  }
  auto it = portDir.find(name);
  printf("%s|%s|%s|%s|%s|ELEM=%s|TS=%s|DIR=%s\n", ownerKind, owner.c_str(),
         name.c_str(), cont, UhdmName(k).data(), ek.c_str(), ts.c_str(),
         it == portDir.end() ? "-" : dirName(it->second));
}

int main(int argc, char** argv) {
  if (argc < 2) { fprintf(stderr, "usage: sig88 <db>\n"); return 2; }
  Serializer s;
  if (s.Restore(std::string(argv[1])).empty()) { fprintf(stderr, "EMPTY\n"); return 3; }
  for (const auto& [obj, id] : s.AllObjects()) {
    std::string owner; const char* ownerKind = nullptr;
    const std::vector<net*>* nets = nullptr;
    const std::vector<variables*>* vars = nullptr;
    const std::vector<array_net*>* anets = nullptr;
    const std::vector<port*>* ports = nullptr;
    if (const module_inst* m = any_cast<const module_inst*>(obj)) {
      owner = m->VpiFullName(); ownerKind = "module_inst";
      nets = m->Nets(); vars = m->Variables(); anets = m->Array_nets();
      ports = m->Ports();
    } else if (const gen_scope* g = any_cast<const gen_scope*>(obj)) {
      owner = g->VpiFullName(); ownerKind = "gen_scope";
      nets = g->Nets(); vars = g->Variables(); anets = g->Array_nets();
    } else if (const interface_inst* i = any_cast<const interface_inst*>(obj)) {
      owner = i->VpiFullName(); ownerKind = "interface_inst";
      nets = i->Nets(); vars = i->Variables(); anets = i->Array_nets();
      ports = i->Ports();
    } else continue;
    std::map<std::string, int> portDir;
    if (ports) for (auto* p : *ports)
      portDir[std::string(p->VpiName())] = p->VpiDirection();
    if (nets)  for (auto* n : *nets)  row(ownerKind, owner, std::string(n->VpiName()), "NET",  n, portDir);
    if (vars)  for (auto* v : *vars)  row(ownerKind, owner, std::string(v->VpiName()), "VAR",  v, portDir);
    if (anets) for (auto* a : *anets) row(ownerKind, owner, std::string(a->VpiName()), "ANET", a, portDir);
  }
  return 0;
}
