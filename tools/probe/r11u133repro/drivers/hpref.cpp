// hpref: every hier_path reached in the listener walk: for each path element,
// its position (i/n), kind, name, stored full name (vpi), span; plus walk
// context and the hier_path's own name/span. Measurement only (r11u133).
#include <uhdm/Serializer.h>
#include <uhdm/VpiListener.h>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_visitor.h>
#include <iostream>
#include <memory>
#include <string>
#include <vector>
namespace {
std::string sp(const UHDM::any* o) {
  return std::to_string(o->VpiLineNo()) + ":" + std::to_string(o->VpiColumnNo()) + "-" +
         std::to_string(o->VpiEndLineNo()) + ":" + std::to_string(o->VpiEndColumnNo());
}
std::string tn(const UHDM::any* o) {
  if (!o) return "NULL";
  std::string s = UHDM::UhdmName(o->UhdmType());
  if (!o->VpiName().empty()) s += "(" + std::string(o->VpiName()) + ")";
  return s;
}
class L : public UHDM::VpiListener {
 public:
  void enterAny(const UHDM::any* o, vpiHandle h) override {
    if (o->UhdmType() != UHDM::uhdmhier_path) return;
    auto* hp = (const UHDM::hier_path*)o;
    std::string ctx;
    for (int i = (int)callstack.size() - 1, n = 0; i >= 0 && n < 4; --i, ++n)
      ctx += std::string(n ? "<" : "") + tn(callstack[i]);
    auto* pe = hp->Path_elems();
    int n = pe ? (int)pe->size() : 0;
    std::cout << "HP\t" << hp->VpiName() << "\t" << sp(o) << "\t" << n << "\t" << ctx << "\n";
    for (int i = 0; i < n; ++i) {
      auto* e = (*pe)[i];
      const char* fn = nullptr;
      vpiHandle eh = NewVpiHandle(e);
      fn = vpi_get_str(vpiFullName, eh);
      vpi_free_object(eh);
      std::string par = !e->VpiParent() ? "NULL" : (e->VpiParent() == o ? "=hp" : tn(e->VpiParent()));
      std::cout << "E\t" << i << "/" << n << "\t" << tn(e) << "\t[" << (fn ? fn : "") << "]\t" << sp(e) << "\t" << par << "\n";
    }
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
