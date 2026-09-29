#include <uhdm/Serializer.h>
#include <uhdm/BaseClass.h>
#include <cstdio>
#include <vector>
#include <algorithm>
#include <tuple>
int main(int argc, char** argv) {
  UHDM::Serializer s;
  s.Restore(std::string(argv[1]));
  std::vector<std::tuple<uintptr_t, int, unsigned, std::string, unsigned>> v;
  for (auto& kv : s.AllObjects()) {
    auto* o = (const UHDM::BaseClass*)kv.first;
    v.emplace_back((uintptr_t)o, (int)o->UhdmType(), o->UhdmId(), std::string(o->VpiName()),
                   o->VpiParent() ? o->VpiParent()->UhdmId() : 0);
  }
  std::sort(v.begin(), v.end());
  // print per kind, the sequence of ids in address (storage) order
  for (auto& [a, t, id, n, p] : v) printf("%d\t%u\t%s\t%u\n", t, id, n.c_str(), p);
}
