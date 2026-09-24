// mutate: change ONE judge-blind field of ONE object of a UHDM database, so the
// strict comparator's canonical walk can be tested against a known content
// difference (tools/probe/r11u123canon, question 1).
//
//   mutate <in.uhdm> --list                      index type name incanon (raw walk order)
//   mutate <in.uhdm> <out.uhdm> <index> endcol|line|value <new>
//
// <index> is the object's position among the objects the raw VpiListener walk
// ENTERS (each object once, first reach), the same walk uhdm-strictcmp --no-canon
// records. incanon = 1 when a typespec or enum_const is on the path at the first
// reach (the object lies in a subtree the canonical walk re-expands).
#include <uhdm/Serializer.h>
#include <uhdm/VpiListener.h>
#include <uhdm/uhdm.h>

#include <iostream>
#include <string>
#include <vector>

namespace {
bool root(const UHDM::any* o) {
  return dynamic_cast<const UHDM::typespec*>(o) != nullptr ||
         o->UhdmType() == UHDM::uhdmenum_const;
}
struct L : UHDM::VpiListener {
  std::vector<const UHDM::any*> objs;
  std::vector<int> inCanon;
  void enterAny(const UHDM::any* o, vpiHandle) override {
    bool c = false;
    for (auto* p : callstack) if (root(p)) { c = true; break; }
    objs.push_back(o);
    inCanon.push_back(c || root(o));
  }
};
}  // namespace

int main(int argc, char** argv) {
  if (argc < 3) { std::cerr << "usage\n"; return 3; }
  UHDM::Serializer s;
  std::vector<vpiHandle> h = s.Restore(std::string(argv[1]));
  L l;
  l.listenDesigns(h);
  if (std::string(argv[2]) == "--list") {
    for (size_t i = 0; i < l.objs.size(); ++i)
      std::cout << i << '\t' << UHDM::UhdmName(l.objs[i]->UhdmType()) << '\t'
                << l.objs[i]->VpiName() << '\t' << l.inCanon[i] << '\n';
    return 0;
  }
  if (argc != 6) { std::cerr << "usage\n"; return 3; }
  size_t idx = std::stoul(argv[3]);
  std::string field = argv[4], val = argv[5];
  if (idx >= l.objs.size()) { std::cerr << "index out of range\n"; return 3; }
  auto* o = const_cast<UHDM::any*>(l.objs[idx]);
  if (field == "endcol") o->VpiEndColumnNo((uint16_t)std::stoul(val));
  else if (field == "line") o->VpiLineNo(std::stoul(val));
  else if (field == "value") {
    auto* e = dynamic_cast<UHDM::expr*>(o);
    if (!e) { std::cerr << "not an expr\n"; return 4; }
    e->VpiValue(val);
  } else { std::cerr << "field?\n"; return 3; }
  s.Save(std::string(argv[2]));
  return 0;
}
