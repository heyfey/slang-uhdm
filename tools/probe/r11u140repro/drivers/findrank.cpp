// findrank <db> <type> <p1type@line:col|*> [<p2type@line:col|*> ...]: every object of <type>
// whose vpiParent chain matches, with its UhdmId and its creation rank among its type
// (the call count of Serializer::Make<type>; gdb `ignore <rank-1>`). Measurement only.
#include <uhdm/Serializer.h>
#include <uhdm/uhdm.h>
#include <algorithm>
#include <iostream>
#include <map>
#include <string>
#include <vector>
int main(int argc, char** argv) {
  if (argc < 3) return 2;
  UHDM::Serializer s;
  auto h = s.Restore(std::string(argv[1]));
  std::string T = argv[2];
  if (T == "tsof") {  // tsof <operation id>: the operation's Typespec ref and its rank
    uint32_t want = std::stoul(argv[3]);
    std::vector<std::pair<uint32_t, const UHDM::BaseClass*>> rts;
    const UHDM::BaseClass* hit = nullptr;
    for (auto& kv : s.AllObjects()) {
      auto* o = (const UHDM::BaseClass*)kv.first;
      if (o->UhdmType() == UHDM::uhdmref_typespec) rts.push_back({o->UhdmId(), o});
      if (o->UhdmType() == UHDM::uhdmoperation && o->UhdmId() == want)
        hit = ((const UHDM::operation*)o)->Typespec();
    }
    std::sort(rts.begin(), rts.end());
    for (size_t r = 0; r < rts.size(); ++r)
      if (rts[r].second == hit)
        std::cout << "ref_typespec rank=" << r + 1 << " id=" << rts[r].first << " parent="
                  << (hit->VpiParent() ? UHDM::UhdmName(hit->VpiParent()->UhdmType()) : "NULL")
                  << " full=" << ((const UHDM::ref_typespec*)hit)->VpiFullName() << "\n";
    return 0;
  }
  std::vector<std::pair<uint32_t, const UHDM::BaseClass*>> v;
  for (auto& kv : s.AllObjects()) {
    auto* o = (const UHDM::BaseClass*)kv.first;
    if (UHDM::UhdmName(o->UhdmType()) == T) v.push_back({o->UhdmId(), o});
  }
  std::sort(v.begin(), v.end());
  for (size_t r = 0; r < v.size(); ++r) {
    auto* o = v[r].second;
    const UHDM::BaseClass* p = o;
    bool ok = true;
    for (int a = 3; a < argc && ok; ++a) {
      p = p ? p->VpiParent() : nullptr;
      if (!p) { ok = false; break; }
      std::string pat = argv[a];
      if (pat == "*") continue;
      auto at = pat.find('@');
      std::string pt = pat.substr(0, at);
      if (UHDM::UhdmName(p->UhdmType()) != pt) ok = false;
      if (ok && at != std::string::npos) {
        std::string lc = std::to_string(p->VpiLineNo()) + ":" + std::to_string(p->VpiColumnNo());
        if (lc != pat.substr(at + 1)) ok = false;
      }
    }
    if (ok) std::cout << T << " rank=" << r + 1 << " id=" << v[r].first << " name=" << o->VpiName() << "\n";
  }
}
