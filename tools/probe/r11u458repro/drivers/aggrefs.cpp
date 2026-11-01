// aggrefs <db> <typespec name>: every struct/union/enum typespec of that name:
// its id, parent chain, first member ref's stored name, and every ref_typespec
// binding it with that ref's parent chain (r11u458 decoding aid).
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <iostream>
#include <map>
#include <algorithm>
using namespace UHDM;
static std::string ch(const BaseClass* o, int n = 7) {
  std::string s;
  for (int i = 0; i < n && o; i++, o = o->VpiParent())
    s += std::string(i ? " < " : "") + std::string(UhdmName(o->UhdmType())) + ":" +
         std::string(o->VpiName().empty() ? o->VpiDefName() : o->VpiName());
  return s;
}
int main(int argc, char** argv) {
  Serializer s;
  auto h = s.Restore(std::filesystem::path(argv[1]));
  std::string nm = argv[2];
  std::map<const typespec*, std::vector<const ref_typespec*>> refs;
  std::vector<const typespec*> ts;
  for (auto& [o, id] : s.AllObjects()) {
    const any* a = (const any*)o;
    if (a->UhdmType() == uhdmref_typespec) {
      if (auto* t = ((const ref_typespec*)a)->Actual_typespec()) refs[t].push_back((const ref_typespec*)a);
    } else if ((a->UhdmType() == uhdmstruct_typespec || a->UhdmType() == uhdmunion_typespec ||
                a->UhdmType() == uhdmenum_typespec) && a->VpiName() == nm)
      ts.push_back((const typespec*)a);
  }
  std::sort(ts.begin(), ts.end(), [](auto* a, auto* b) { return a->UhdmId() < b->UhdmId(); });
  for (auto* t : ts) {
    std::string m0 = "-";
    const VectorOftypespec_member* ms = nullptr;
    if (t->UhdmType() == uhdmstruct_typespec) ms = ((const struct_typespec*)t)->Members();
    if (t->UhdmType() == uhdmunion_typespec) ms = ((const union_typespec*)t)->Members();
    if (ms && !ms->empty() && ms->front()->Typespec()) {
      auto* mr = ms->front()->Typespec();
      auto* ma = mr->Actual_typespec();
      m0 = std::string(mr->VpiFullName()) + " actual#" + (ma ? std::to_string(ma->UhdmId()) : "-") +
           " inst=" + (ma && ma->Instance() ? std::string(ma->Instance()->VpiName()) : "null") +
           " apar=" + (ma ? ch(ma->VpiParent(), 2) : "-");
    }
    if (t->UhdmType() == uhdmenum_typespec)
      if (auto* b = ((const enum_typespec*)t)->Base_typespec()) m0 = "base:" + std::string(b->VpiFullName());
    std::cout << "#" << t->UhdmId() << " " << UhdmName(t->UhdmType()) << " @" << t->VpiLineNo() << ":"
              << t->VpiColumnNo() << " par=" << ch(t->VpiParent(), 6) << "\n   m0=" << m0 << "\n";
    if (ms && getenv("ALLMEM"))
      for (auto* m : *ms) {
        auto* mr = m->Typespec(); auto* ma = mr ? mr->Actual_typespec() : nullptr;
        const ref_typespec* al = nullptr;
        if (ma && ma->UhdmType() == uhdmbit_typespec) al = ((const bit_typespec*)ma)->Typedef_alias();
        std::cout << "   mem " << m->VpiName() << " mrpar=" << (mr && mr->VpiParent() == m) << " ma#" << (ma ? ma->UhdmId() : 0)
                  << " ma=" << (ma ? std::string(ma->VpiName()) : "-") << " mapar=" << (ma ? ch(ma->VpiParent(), 3) : "-")
                  << " al=" << (al ? std::string(al->VpiFullName()) + " alpar_ok=" + std::to_string(al->VpiParent() == ma) : "-")
                  << " nrefs=" << refs[ma].size() << "\n";
      }
    auto& rv = refs[t];
    std::sort(rv.begin(), rv.end(), [](auto* a, auto* b) { return a->UhdmId() < b->UhdmId(); });
    for (auto* r : rv) std::cout << "   ref#" << r->UhdmId() << " " << ch(r->VpiParent(), 6) << "\n";
  }
}
