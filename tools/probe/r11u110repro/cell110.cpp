// r11u110 -- PER-CELL scorer for elaborated port / variable / type-parameter
// typespecs (measurement only; uhdm-cmp is the judge).  Restores the golden
// and one of our databases, walks each TopModules tree (module_inst, gen_scope
// arrays, gen scopes), and keys every cell by NAME PATH:
//   PORT  <instance fullname>.<port>      -> port vpiTypedef actual
//   VAR   <instance fullname>.<variable>  -> variable kind + vpiTypespec actual
//   TPAR  <instance fullname>.<param>     -> type_parameter vpiTypespec actual
// and compares golden's object with ours with a FRESH CompareContext per cell
// (so no visited-set masking).  Interface instances (vpiInterface of a
// module / generate scope) contribute their PORT and VAR cells.  Prints "<cell> EQ|NE|GOLD-ONLY|OURS-ONLY".
// build: g++ -O2 -std=c++17 cell110.cpp -I ~/.local/include -L ~/.local/lib64 \
//        -L ~/.local/lib -luhdm -lcapnp -lkj -o cell110
// usage: cell110 <golden.uhdm> <ours.uhdm>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <map>
#include <string>
using namespace UHDM;
typedef std::map<std::string, const any*> Cells;
static void walk(const any* o, Cells& c) {
  if (!o) return;
  if (o->UhdmType() == uhdmmodule_inst) {
    auto* mi = (const module_inst*)o;
    std::string pre(mi->VpiFullName());
    if (mi->Ports())
      for (auto* p : *mi->Ports())
        c["PORT " + pre + "." + std::string(p->VpiName())] =
            p->Typespec() ? (const any*)p->Typespec()->Actual_typespec() : nullptr;
    if (mi->Variables())
      for (auto* v : *mi->Variables())
        c["VAR  " + pre + "." + std::string(v->VpiName())] = v;
    if (mi->Parameters())
      for (auto* p : *mi->Parameters())
        if (p->UhdmType() == uhdmtype_parameter) {
          auto* tp = (const type_parameter*)p;
          c["TPAR " + pre + "." + std::string(p->VpiName())] =
              tp->Typespec() ? (const any*)tp->Typespec()->Actual_typespec() : nullptr;
        }
    if (mi->Modules()) for (auto* m : *mi->Modules()) walk(m, c);
    if (mi->Interfaces()) for (auto* m : *mi->Interfaces()) walk(m, c);
    if (mi->Gen_scope_arrays()) for (auto* g : *mi->Gen_scope_arrays()) walk(g, c);
  } else if (o->UhdmType() == uhdminterface_inst) {
    auto* ii = (const interface_inst*)o;
    std::string pre(ii->VpiFullName());
    if (ii->Ports())
      for (auto* p : *ii->Ports())
        c["PORT " + pre + "." + std::string(p->VpiName())] =
            p->Typespec() ? (const any*)p->Typespec()->Actual_typespec() : nullptr;
    if (ii->Variables())
      for (auto* v : *ii->Variables())
        c["VAR  " + pre + "." + std::string(v->VpiName())] = v;
  } else if (o->UhdmType() == uhdmgen_scope_array) {
    auto* ga = (const gen_scope_array*)o;
    if (ga->Gen_scopes()) for (auto* g : *ga->Gen_scopes()) walk(g, c);
  } else if (o->UhdmType() == uhdmgen_scope) {
    auto* g = (const gen_scope*)o;
    std::string pre(g->VpiFullName());
    if (g->Variables())
      for (auto* v : *g->Variables())
        c["VAR  " + pre + "." + std::string(v->VpiName())] = v;
    if (g->Modules()) for (auto* m : *g->Modules()) walk(m, c);
    if (g->Interfaces()) for (auto* m : *g->Interfaces()) walk(m, c);
    if (g->Gen_scope_arrays()) for (auto* x : *g->Gen_scope_arrays()) walk(x, c);
  }
}
static Cells load(Serializer& s, const char* f) {
  Cells c;
  auto hs = s.Restore(std::string(f));
  for (auto h : hs) {
    auto* d = (const design*)((uhdm_handle*)h)->object;
    if (d->UhdmType() != uhdmdesign || !d->TopModules()) continue;
    for (auto* t : *d->TopModules()) walk(t, c);
  }
  return c;
}
int main(int argc, char** argv) {
  if (argc < 3) return 2;
  Serializer sg, so;
  Cells g = load(sg, argv[1]);
  Cells o = load(so, argv[2]);
  for (auto& [k, gv] : g) {
    auto it = o.find(k);
    if (it == o.end()) { printf("%s GOLD-ONLY\n", k.c_str()); continue; }
    const any* ov = it->second;
    const char* r;
    if (!gv && !ov) r = "EQ";
    else if (!gv || !ov) r = "NE";
    else {
      CompareContext cc;
      r = gv->Compare(ov, &cc) == 0 ? "EQ" : "NE";
    }
    printf("%s %s\n", k.c_str(), r);
  }
  for (auto& [k, ov] : o)
    if (!g.count(k)) printf("%s OURS-ONLY\n", k.c_str());
  return 0;
}
