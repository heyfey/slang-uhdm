// r10earl77 — PORT-BACKING OBJECT CENSUS.  For every module_inst in one .uhdm
// database, print one row per PORT: the port's direction, its typespec kind and
// name, the KIND of the Nets/Variables entry that backs it (matched by name),
// which CONTAINER that entry lives in, and the kind/name of the port's
// Low_conn.  Also prints the port's own file:line:col so a post-pass can read
// the WRITTEN type text out of the source.  MEASUREMENT ONLY.
//   build: g++ -O2 -std=c++17 cen77.cpp -I ~/.local/include \
//              -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o cen77
//   usage: cen77 <db.uhdm> [defname-filter]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <uhdm/Serializer.h>
#include <cstdio>
#include <map>
#include <string>
using namespace UHDM;

static const char* dirName(int d) {
  switch (d) {
    case vpiInput: return "IN";
    case vpiOutput: return "OUT";
    case vpiInout: return "INOUT";
    case vpiMixedIO: return "MIXED";
    case vpiNoDirection: return "NODIR";
    default: return "?";
  }
}

static std::string tsDesc(const ref_typespec* rt) {
  if (!rt) return "none";
  const typespec* t = rt->Actual_typespec();
  if (!t) return "nullactual";
  std::string k(UhdmName(t->UhdmType()));
  std::string n(t->VpiName());
  return k + "/" + (n.empty() ? std::string("<anon>") : n);
}

int main(int argc, char** argv) {
  if (argc < 2) { fprintf(stderr, "usage: cen77 <db> [deffilter]\n"); return 2; }
  const char* filt = argc > 2 ? argv[2] : nullptr;
  Serializer s;
  if (s.Restore(std::string(argv[1])).empty()) { fprintf(stderr, "EMPTY\n"); return 3; }
  for (const auto& [obj, id] : s.AllObjects()) {
    const module_inst* m = any_cast<const module_inst*>(obj);
    if (!m) continue;
    std::string def(m->VpiDefName());
    if (filt && def.find(filt) == std::string::npos) continue;
    std::string full(m->VpiFullName());
    // index the containers by name
    std::map<std::string, std::string> byName;   // name -> "NET:kind" / "VAR:kind"
    if (m->Nets())
      for (auto* n : *m->Nets())
        byName[std::string(n->VpiName())] = "NET:" + std::string(UhdmName(n->UhdmType()));
    if (m->Variables())
      for (auto* v : *m->Variables())
        byName[std::string(v->VpiName())] = "VAR:" + std::string(UhdmName(v->UhdmType()));
    if (m->Array_nets())
      for (auto* v : *m->Array_nets())
        byName[std::string(v->VpiName())] = "ANET:" + std::string(UhdmName(v->UhdmType()));
    if (!m->Ports()) continue;
    for (auto* p : *m->Ports()) {
      std::string pn(p->VpiName());
      auto it = byName.find(pn);
      std::string back = it == byName.end() ? std::string("<none>") : it->second;
      std::string lc = "<none>";
      if (const any* l = p->Low_conn()) {
        lc = std::string(UhdmName(l->UhdmType()));
        if (l->UhdmType() == uhdmref_obj) {
          const ref_obj* r = (const ref_obj*)l;
          const any* a = r->Actual_group();
          lc += "->" + (a ? std::string(UhdmName(a->UhdmType())) : std::string("<null>"));
        }
      }
      printf("DEF=%s|PORT=%s|DIR=%s|TS=%s|BACK=%s|LOWCONN=%s|LOC=%s:%d:%d|INST=%s\n",
             def.c_str(), pn.c_str(), dirName(p->VpiDirection()),
             tsDesc(p->Typespec()).c_str(), back.c_str(), lc.c_str(),
             std::string(p->VpiFile()).c_str(), p->VpiLineNo(), p->VpiColumnNo(),
             full.c_str());
    }
  }
  return 0;
}
