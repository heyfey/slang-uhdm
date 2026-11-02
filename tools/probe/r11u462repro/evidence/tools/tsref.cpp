// tsref <db.uhdm> <fullname>: for every variable with that full name, print its typespec, the
// typespec's typedef-alias target and every ref_typespec in the database whose actual is that target
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <iostream>
using namespace UHDM;
static std::string ch(const BaseClass* o, int n = 9) {
  if (!o) return "null";
  std::string s;
  for (int i = 0; i < n && o; i++, o = o->VpiParent())
    s += std::string(i ? " < " : "") + std::string(UhdmName(o->UhdmType())) + ":" + std::string(o->VpiName()) + "#" + std::to_string(o->UhdmId()) + "@" + std::to_string(o->VpiLineNo()) + ":" + std::to_string(o->VpiColumnNo());
  return s;
}
static const typespec* alias(const typespec* t) {
  if (!t) return nullptr;
  const ref_typespec* r = t->Typedef_alias();
  return r ? r->Actual_typespec() : nullptr;
}
int main(int argc, char** argv) {
  Serializer s; auto h = s.Restore(std::filesystem::path(argv[1])); std::string fn = argv[2];
  std::vector<const ref_typespec*> refs; std::vector<const typespec*> targets;
  for (auto& kv : s.AllObjects()) {
    auto* o = (const BaseClass*)kv.first;
    if (o->UhdmType() == uhdmref_typespec) refs.push_back((const ref_typespec*)o);
  }
  for (auto& kv : s.AllObjects()) {
    auto* o = (const BaseClass*)kv.first;
    auto* v = any_cast<const variables*>(o);
    if (!v || v->VpiFullName() != fn) continue;
    auto* r = v->Typespec(); auto* t = r ? r->Actual_typespec() : nullptr;
    std::cout << "VAR " << ch(v) << "\n  TS " << ch(t) << "\n";
    for (int k = 0; k < 4 && t; k++) {
      auto* a = alias(t);
      std::cout << "  ALIAS" << k << " " << ch(a) << "\n";
      t = a;
      if (a) targets.push_back(a);
    }
  }
  for (auto* t : targets) {
    int n = 0;
    for (auto* r : refs) if (r->Actual_typespec() == t) {
      if (n++ < 12) {
        std::cout << "  REF->" << t->UhdmId() << " " << ch(r, 6) << "\n";
        auto* copy = r->VpiParent();
        for (auto* u : refs) if (u->Actual_typespec() == copy) std::cout << "      USE " << ch(u, 7) << "\n";
      }
    }
    std::cout << "  refs to #" << t->UhdmId() << ": " << n << "\n";
  }
}
