// r10uvm98 — MEASUREMENT-ONLY.  The A-PRIORI MOVER PREDICTOR, read from OUR
// PRISTINE databases alone (never golden, never the patched binary).
//
// § bareTdNameFirstWriterWins98 can only change a database in which some BARE
// typedef name is declared by MORE THAN ONE class with DIFFERENT targets: when
// a name has exactly one meaning design-wide, the first writer IS the
// declaration the reference already resolves to and the model is the identity.
// So the NECESSARY condition, computable from the pristine database alone:
//
//   there is a SITE (io_decl / variables / function return) whose typespec is a
//   class_typespec X, and the database holds another class_typespec Y with the
//   SAME bare name (the text after the last "::" of VpiName) and a DIFFERENT
//   Class_defn.
//
// This is a SUPERSET — it knows neither the winner nor whether the reference is
// out of `getDataType`'s reach — so PREDICTED >= MOVERS, and a database it does
// NOT name can never move.  That is what makes it a FENCE.
//
// build: g++ -O2 -std=c++17 pred98.cpp -I ~/.local/include \
//        -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o pred98
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <string>
#include <vector>
#include <set>
#include <map>
#include <algorithm>
using namespace UHDM;

static std::string fn(const BaseClass* p) {
  if (!p) return "-";
  vpiHandle h = NewVpiHandle(p);
  const char* s = h ? vpi_get_str(vpiFullName, h) : nullptr;
  std::string r = s ? s : std::string();
  if (h) vpi_free_object(h);
  if (r.empty()) r = std::string(p->VpiName());
  return r.empty() ? "<anon>" : r;
}
static std::string bare(std::string_view n) {
  auto p = n.rfind("::");
  return std::string(p == std::string_view::npos ? n : n.substr(p + 2));
}

int main(int argc, char** argv) {
  Serializer s;
  if (s.Restore(std::string(argv[1])).empty()) { printf("RESTORE_FAILED\n"); return 3; }
  std::map<std::string, std::set<std::string>> defnsOfName;
  std::vector<std::pair<std::string, const class_typespec*>> sites;
  for (auto& p : s.AllObjects()) {
    const BaseClass* o = p.first;
    if (!o) continue;
    if (o->UhdmType() == uhdmclass_typespec) {
      auto* ct = (const class_typespec*)o;
      if (!ct->VpiName().empty())
        defnsOfName[bare(ct->VpiName())].insert(fn(ct->Class_defn()));
      continue;
    }
    const ref_typespec* rt = nullptr;
    std::string who;
    if (o->UhdmType() == uhdmio_decl) { rt = ((const io_decl*)o)->Typespec(); who = "IODECL"; }
    else if (o->UhdmType() == uhdmfunction) {
      if (const variables* rv = ((const function*)o)->Return()) rt = rv->Typespec();
      who = "RETURN";
    }
    else if (auto* v = any_cast<const variables*>(o)) { rt = v->Typespec(); who = "VAR"; }
    if (!rt) continue;
    const typespec* a = rt->Actual_typespec();
    if (!a || a->UhdmType() != uhdmclass_typespec) continue;
    if (a->VpiName().empty()) continue;
    sites.emplace_back(who, (const class_typespec*)a);
  }
  std::set<std::string> hits;
  for (auto& [who, ct] : sites) {
    const std::string b = bare(ct->VpiName());
    auto it = defnsOfName.find(b);
    if (it == defnsOfName.end() || it->second.size() < 2) continue;
    hits.insert(who + "\t" + b + "\t" + fn(ct->Class_defn()));
  }
  for (auto& h : hits) printf("%s\n", h.c_str());
  printf("CANMOVE %zu\n", hits.size());
  return 0;
}
