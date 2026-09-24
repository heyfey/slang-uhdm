// hpcensus: every hier_path (listener walk order, each object once) with its
// span, parent kind and each Path_elems element: type, name, span, the
// full name vpi_get_str(vpiFullName) prints (empty when == name), and the
// element's vpiParent kind. Measurement only (r11u124).
#include <uhdm/Serializer.h>
#include <uhdm/VpiListener.h>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_visitor.h>
#include <iostream>
#include <memory>
#include <set>
#include <string>
#include <vector>
namespace {
std::string sp(const UHDM::BaseClass* o) {
  return std::to_string(o->VpiLineNo()) + ":" + std::to_string(o->VpiColumnNo()) + "-" +
         std::to_string(o->VpiEndLineNo()) + ":" + std::to_string(o->VpiEndColumnNo());
}
std::string fnOf(const UHDM::BaseClass* o) {
  std::string_view f;
  if (auto* r = dynamic_cast<const UHDM::ref_obj*>(o)) f = r->VpiFullName();
  else return "?";
  if (f == o->VpiName()) return "";
  return std::string(f);
}
class L : public UHDM::VpiListener {
 public:
  std::set<const UHDM::any*> seen;
  void enterHier_path(const UHDM::hier_path* h, vpiHandle) override {
    if (!seen.insert(h).second) return;
    std::string ctx;
    int n = 0;
    for (const UHDM::BaseClass* p = h->VpiParent(); p && n < 4; p = p->VpiParent(), ++n)
      ctx += std::string(n ? "<" : "") + UHDM::UhdmName(p->UhdmType());
    std::cout << "HP\t" << h->VpiName() << "\t" << sp(h) << "\t" << ctx;
    if (h->Path_elems())
      for (auto* e : *h->Path_elems()) {
        std::cout << "\t" << UHDM::UhdmName(e->UhdmType()) << "(" << e->VpiName() << ")@" << sp(e)
                  << "{fn=" << fnOf(e) << ",par=" << (e->VpiParent() == h ? "hp" : (e->VpiParent() ? UHDM::UhdmName(e->VpiParent()->UhdmType()) : "NULL")) << "}";
      }
    std::cout << "\n";
  }
};
}  // namespace
int main(int argc, char** argv) {
  if (argc < 2) return 3;
  auto ser = std::make_unique<UHDM::Serializer>();
  std::vector<vpiHandle> h = ser->Restore(std::string(argv[1]));
  L l;
  l.listenDesigns(h);
  return 0;
}
