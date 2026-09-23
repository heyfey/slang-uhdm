// r11u108 -- WHO REFERENCES WHAT (measurement only; uhdm-cmp is the judge).
// Restores a .uhdm, walks it with the UhdmListener, and for every typespec
// whose VpiName equals argv[2] (or every typespec when argv[2] is "*") prints
// its id, kind, span, vpiParent, vpiInstance, typedef-alias target, and every
// ref_typespec (with the ref's own parent) that points at it, plus the first
// listener path that reaches it.  Ids are the ones uhdm-cmp prints.
// build: g++ -O2 -std=c++17 who108.cpp -I ~/.local/include -L ~/.local/lib64 \
//        -L ~/.local/lib -luhdm -lcapnp -lkj -o who108
// usage: who108 <file.uhdm> <name|*>
#include <uhdm/uhdm.h>
#include <uhdm/UhdmListener.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <map>
#include <set>
#include <string>
#include <vector>
using namespace UHDM;
static std::string desc(const any* o) {
  if (!o) return "<null>";
  char b[640];
  snprintf(b, sizeof b, "%s(%s) id:%u %u:%u-%u:%u", UhdmName(o->UhdmType()).data(),
           std::string(o->VpiName()).c_str(), o->UhdmId(), o->VpiLineNo(),
           (unsigned)o->VpiColumnNo(), o->VpiEndLineNo(), (unsigned)o->VpiEndColumnNo());
  return b;
}
struct L : public UhdmListener {
  std::string want;
  std::map<const typespec*, std::vector<std::string>> path;
  std::map<const typespec*, std::vector<const ref_typespec*>> refs;
  std::vector<const typespec*> order;
  bool match(const any* o) {
    if (!o) return false;
    if (!dynamic_cast<const typespec*>(o)) return false;
    return want == "*" || std::string(o->VpiName()) == want;
  }
  void enterAny(const any* const o) override {
    if (o->UhdmType() == uhdmref_typespec) {
      auto* r = (const ref_typespec*)o;
      if (auto* a = r->Actual_typespec(); match(a)) refs[a].push_back(r);
    }
    if (!match(o)) return;
    auto* t = (const typespec*)o;
    if (path.count(t)) return;
    order.push_back(t);
    for (auto* c : getCallstack()) path[t].push_back(desc(c));
  }
};
int main(int argc, char** argv) {
  Serializer s;
  auto hs = s.Restore(std::string(argv[1]));
  L l;
  l.want = argv[2];
  for (auto h : hs) l.listenAny((const any*)((uhdm_handle*)h)->object);
  for (auto* t : l.order) {
    printf("== %s parent=%s inst=%s", desc(t).c_str(), desc(t->VpiParent()).c_str(),
           desc(t->Instance()).c_str());
    if (auto* ta = t->Typedef_alias())
      printf(" alias=[%s -> %s]", desc(ta).c_str(), desc(ta->Actual_typespec()).c_str());
    printf("\n");
    for (auto& p : l.path[t]) printf("   < %s\n", p.c_str());
    for (auto* r : l.refs[t])
      printf("   REF %s fullname=%s parent=%s\n", desc(r).c_str(),
             std::string(r->VpiFullName()).c_str(), desc(r->VpiParent()).c_str());
  }
  return 0;
}
