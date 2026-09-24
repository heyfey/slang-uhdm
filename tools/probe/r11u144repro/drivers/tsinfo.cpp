// tsinfo <db> : every array_typespec: id, parent, ranges, and who references it (ref_typespec ids + their parents)
#include <uhdm/uhdm.h>
#include <uhdm/Serializer.h>
#include <iostream>
#include <map>
using namespace UHDM;
int main(int argc, char** argv) {
  Serializer s; s.Restore(std::string(argv[1]));
  std::multimap<const BaseClass*, const ref_typespec*> refs;
  for (auto& [o, id] : s.AllObjects()) {
    const BaseClass* b = o;
    if (b->UhdmType() == uhdmref_typespec) { auto* r = (const ref_typespec*)b; if (r->Actual_typespec()) refs.insert({r->Actual_typespec(), r}); }
  }
  for (auto& [o, id] : s.AllObjects()) {
    const BaseClass* b = o;
    if (b->UhdmType() != uhdmarray_typespec) continue;
    auto* a = (const array_typespec*)b;
    std::cout << "array_typespec id=" << b->UhdmId() << " " << b->VpiLineNo() << ":" << b->VpiColumnNo()
              << " parent=" << (b->VpiParent() ? UhdmName(b->VpiParent()->UhdmType()) + std::to_string(b->VpiParent()->UhdmId()) : std::string("-"))
              << " ranges=" << (a->Ranges() ? a->Ranges()->size() : 0) << " elem=" << (a->Elem_typespec() ? a->Elem_typespec()->UhdmId() : 0) << " refby:";
    auto rg = refs.equal_range(b);
    for (auto it = rg.first; it != rg.second; ++it) { auto* p = it->second->VpiParent(); std::cout << " " << it->second->UhdmId() << "<" << (p ? UhdmName(p->UhdmType()) + std::to_string(p->UhdmId()) : "-") ; if (p && p->VpiParent()) std::cout << "<" << UhdmName(p->VpiParent()->UhdmType()) << p->VpiParent()->UhdmId(); }
    std::cout << "\n";
  }
}
