// r11u223: list every object of a UHDM database in UhdmId order: id, type, name, line:col (for order-only diffs).
#include <uhdm/uhdm.h>
#include <uhdm/Serializer.h>
#include <cstdio>
#include <vector>
#include <algorithm>
#include <uhdm/ref_typespec.h>
#include <uhdm/io_decl.h>
int main(int argc, char** argv) {
  UHDM::Serializer s;
  auto designs = s.Restore(std::string(argv[1]));
  std::vector<const UHDM::BaseClass*> v;
  for (auto& kv : s.AllObjects()) if (kv.first) v.push_back(kv.first);
  std::sort(v.begin(), v.end(), [](auto a, auto b){ return a->UhdmId() < b->UhdmId(); });
  for (auto* o : v) {
    unsigned par = o->VpiParent() ? o->VpiParent()->UhdmId() : 0, act = 0;
    if (o->UhdmType() == UHDM::uhdmref_typespec) { auto* a = ((const UHDM::ref_typespec*)o)->Actual_typespec(); act = a ? a->UhdmId() : 0; }
    if (o->UhdmType() == UHDM::uhdmio_decl) { auto* a = ((const UHDM::io_decl*)o)->Typespec(); act = a ? a->UhdmId() : 0; }
    printf("%u %d %s %u:%u-%u:%u %s par=%u act=%u\n", o->UhdmId(), (int)o->UhdmType(), std::string(o->VpiName()).c_str(), o->VpiLineNo(), o->VpiColumnNo(), o->VpiEndLineNo(), o->VpiEndColumnNo(), std::string(o->VpiFile()).substr(std::string(o->VpiFile()).rfind('/')+1).c_str(), par, act);
  }
}
