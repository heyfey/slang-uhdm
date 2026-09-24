// mutate: change ONE judge-blind field of ONE object of a UHDM database (tools/probe/r11u129canon;
// extends r11u123canon/drivers/mutate.cpp with full names and parent links).
//
//   mutate <in.uhdm> --list                      index type name incanon fullname parentindex
//   mutate <in.uhdm> <out.uhdm> <index> endcol|line|file|value|fullname <new>   (file "-" = empty)
//   mutate <in.uhdm> <out.uhdm> <index> parent <index2>   (re-point VpiParent: a parenting defect)
//
// <index> is the object's position among the objects the raw VpiListener walk ENTERS (each object
// once, first reach). incanon = 1 when a typespec or enum_const is on the path at the first reach.
#include <uhdm/Serializer.h>
#include <uhdm/VpiListener.h>
#include <uhdm/uhdm.h>

#include <iostream>
#include <map>
#include <string>
#include <vector>

namespace {
bool root(const UHDM::any* o) {
  return dynamic_cast<const UHDM::typespec*>(o) != nullptr || o->UhdmType() == UHDM::uhdmenum_const;
}
struct L : UHDM::VpiListener {
  std::vector<const UHDM::any*> objs;
  std::vector<int> inCanon;
  std::vector<std::string> full;
  bool names = false;  // --list only: reading a full name CACHES it in the object, and a later
                       // Save would store it (a re-parenting would then be invisible)
  void enterAny(const UHDM::any* o, vpiHandle h) override {
    bool c = false;
    for (auto* p : callstack) if (root(p)) { c = true; break; }
    objs.push_back(o);
    inCanon.push_back(c || root(o));
    const char* f = names ? vpi_get_str(vpiFullName, h) : nullptr;
    full.push_back(f ? f : "");
  }
};
bool setFull(UHDM::any* o, const std::string& v) {
#define TRY(T) if (auto* x = dynamic_cast<UHDM::T*>(o)) { x->VpiFullName(v); return true; }
  TRY(ref_typespec) TRY(ref_obj) TRY(parameter) TRY(type_parameter) TRY(variables) TRY(nets)
  TRY(hier_path) TRY(scope) TRY(named_event) TRY(constraint) TRY(gen_var) TRY(property_decl)
  TRY(sequence_decl) TRY(primitive) TRY(concurrent_assertions) TRY(instance_array) TRY(gen_scope_array)
#undef TRY
  return false;
}
}  // namespace

int main(int argc, char** argv) {
  if (argc < 3) { std::cerr << "usage\n"; return 3; }
  UHDM::Serializer s;
  std::vector<vpiHandle> h = s.Restore(std::string(argv[1]));
  L l;
  l.names = std::string(argv[2]) == "--list";
  l.listenDesigns(h);
  if (std::string(argv[2]) == "--list") {
    std::map<const UHDM::any*, size_t> ix;
    for (size_t i = 0; i < l.objs.size(); ++i) ix[l.objs[i]] = i;
    for (size_t i = 0; i < l.objs.size(); ++i) {
      auto it = ix.find(l.objs[i]->VpiParent());
      std::cout << i << '\t' << UHDM::UhdmName(l.objs[i]->UhdmType()) << '\t' << l.objs[i]->VpiName() << '\t'
                << l.inCanon[i] << '\t' << l.full[i] << '\t' << (it == ix.end() ? -1L : (long)it->second) << '\n';
    }
    return 0;
  }
  if (argc != 6) { std::cerr << "usage\n"; return 3; }
  size_t idx = std::stoul(argv[3]);
  std::string field = argv[4], val = argv[5];
  if (idx >= l.objs.size()) { std::cerr << "index out of range\n"; return 3; }
  auto* o = const_cast<UHDM::any*>(l.objs[idx]);
  if (field == "endcol") o->VpiEndColumnNo((uint16_t)std::stoul(val));
  else if (field == "line") o->VpiLineNo(std::stoul(val));
  else if (field == "file") o->VpiFile(val == "-" ? std::string() : val);
  else if (field == "value") {
    auto* e = dynamic_cast<UHDM::expr*>(o);
    if (!e) { std::cerr << "not an expr\n"; return 4; }
    e->VpiValue(val);
  } else if (field == "fullname") {
    if (!setFull(o, val)) { std::cerr << "no full name on this kind\n"; return 4; }
  } else if (field == "parent") {
    size_t j = std::stoul(val);
    if (j >= l.objs.size()) { std::cerr << "index out of range\n"; return 3; }
    o->VpiParent(const_cast<UHDM::any*>(l.objs[j]));
  } else { std::cerr << "field?\n"; return 3; }
  s.Save(std::string(argv[2]));
  return 0;
}
