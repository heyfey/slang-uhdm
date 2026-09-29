// objrank: list every object of a database as
//   type <tab> rank-within-type (creation order, by UhdmId) <tab> id <tab> name <tab> file <tab> line:col:endline:endcol
// The rank is the call count of Serializer::Make<type> that minted it, so a
// gdb breakpoint on that Make with `ignore <rank-1>` stops at the mint site.
#include <uhdm/Serializer.h>
#include <uhdm/uhdm.h>
#include <algorithm>
#include <iostream>
#include <map>
#include <vector>
int main(int argc, char** argv) {
  if (argc < 2) { std::cerr << "usage: objrank db.uhdm\n"; return 2; }
  UHDM::Serializer s;
  auto h = s.Restore(std::string(argv[1]));
  if (h.empty()) return 3;
  std::map<std::string, std::vector<std::pair<uint32_t, const UHDM::BaseClass*>>> by;
  for (auto& kv : s.AllObjects()) {
    const UHDM::BaseClass* o = (const UHDM::BaseClass*)kv.first;
    by[UHDM::UhdmName(o->UhdmType())].push_back({o->UhdmId(), o});
  }
  for (auto& [t, v] : by) {
    std::sort(v.begin(), v.end());
    size_t r = 0;
    for (auto& [id, o] : v) {
      ++r;
      std::string f(o->VpiFile());
      auto p = f.find_last_of('/');
      std::cout << t << '\t' << r << '\t' << id << '\t' << o->VpiName() << '\t'
                << (p == std::string::npos ? f : f.substr(p + 1)) << '\t' << o->VpiLineNo() << ':'
                << o->VpiColumnNo() << ':' << o->VpiEndLineNo() << ':' << o->VpiEndColumnNo() << '\n';
    }
  }
}
