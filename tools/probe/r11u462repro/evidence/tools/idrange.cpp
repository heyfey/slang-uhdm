// idrange <db.uhdm> <lo> <hi>: print every object whose id lies in [lo, hi] with its parent chain
#include <uhdm/uhdm.h>
#include <filesystem>
#include <iostream>
#include <map>
using namespace UHDM;
static std::string ch(const BaseClass* o, int n = 7) {
  if (!o) return "null";
  std::string s;
  for (int i = 0; i < n && o; i++, o = o->VpiParent())
    s += std::string(i ? " < " : "") + std::string(UhdmName(o->UhdmType())) + ":" + std::string(o->VpiName()) + "#" + std::to_string(o->UhdmId()) + "@" + std::to_string(o->VpiLineNo()) + ":" + std::to_string(o->VpiColumnNo());
  return s;
}
int main(int argc, char** argv) {
  Serializer s; auto h = s.Restore(std::filesystem::path(argv[1]));
  long lo = atol(argv[2]), hi = atol(argv[3]);
  std::map<long, const BaseClass*> m;
  for (auto& kv : s.AllObjects()) { auto* o = (const BaseClass*)kv.first; if (o->UhdmId() >= lo && o->UhdmId() <= hi) m[o->UhdmId()] = o; }
  for (auto& [i, o] : m) std::cout << ch(o) << "\n";
}
