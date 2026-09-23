// r11u108 -- CENSUS of the tpPackedArrayTsVar108 shape (measurement only).
// For every VARIABLE reachable under uhdmtopModules (the elaborated view) whose
// vpiTypespec ref points at a packed_array_typespec, prints one line:
//   <kind> <vpiFullName|vpiName> expr=<0|1> ranges=<n> elems=<n>
// The law's shape is a NON-packed_array_var kind (logic_var, bit_var, ...)
// carrying a packed_array_typespec, or a packed_array_var WITH ranges/elements
// (the golden shape carries neither).  Run it on golden AND ours.
// build: g++ -O2 -std=c++17 cen108.cpp -I ~/.local/include -L ~/.local/lib64 \
//        -L ~/.local/lib -luhdm -lcapnp -lkj -o cen108
// usage: cen108 <file.uhdm>
#include <uhdm/uhdm.h>
#include <uhdm/UhdmListener.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <set>
#include <string>
using namespace UHDM;
struct L : public UhdmListener {
  std::set<const any*> seen;
  void enterAny(const any* const o) override {
    auto* v = dynamic_cast<const variables*>(o);
    if (!v || !seen.insert(o).second) return;
    auto* rt = v->Typespec();
    if (!rt || !rt->Actual_typespec()) return;
    if (rt->Actual_typespec()->UhdmType() != uhdmpacked_array_typespec) return;
    int nr = 0, ne = 0;
    if (o->UhdmType() == uhdmpacked_array_var) {
      auto* p = (const packed_array_var*)o;
      nr = p->Ranges() ? (int)p->Ranges()->size() : 0;
      ne = p->Elements() ? (int)p->Elements()->size() : 0;
    }
    std::string n(v->VpiFullName());
    if (n.empty()) n = std::string(v->VpiName());
    printf("%s %s expr=%d ranges=%d elems=%d\n", UhdmName(o->UhdmType()).data(), n.c_str(),
           v->Expr() ? 1 : 0, nr, ne);
  }
};
int main(int argc, char** argv) {
  Serializer s;
  auto hs = s.Restore(std::string(argv[1]));
  L l;
  for (auto h : hs) {
    auto* d = (const design*)((uhdm_handle*)h)->object;
    if (d->UhdmType() != uhdmdesign || !d->TopModules()) continue;
    for (auto* m : *d->TopModules()) l.listenAny(m);
  }
  return 0;
}
