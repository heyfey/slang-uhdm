// tsref: every ref_typespec reached in the listener walk: walk context, its
// VpiParent (type(name), NULL, or =walk when it is the walk parent), the
// actual typespec kind, and the vpiFullName. Measurement only (r11u133).
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
    if (o->UhdmType() != UHDM::uhdmref_typespec) return;
    auto* r = (const UHDM::ref_typespec*)o;
    std::string ctx;
    const UHDM::any* wp = !callstack.empty() ? callstack.back() : nullptr;
    for (int i = (int)callstack.size() - 1, n = 0; i >= 0 && n < 7; --i, ++n) {
      ctx += std::string(n ? "<" : "") + tn(callstack[i]);
      if (callstack[i]->UhdmType() != UHDM::uhdmref_typespec && callstack[i]->VpiLineNo()) ctx += "@" + sp(callstack[i]);
    }
    const UHDM::any* p = o->VpiParent();
    std::string ps = !p ? "NULL" : (p == wp ? "=walk" : tn(p) + "@" + sp(p));
    // the first ancestor (self included) whose VpiParent is null: its kind and hops
    {
      const UHDM::any* x = o; int hops = 0;
      while (x->VpiParent() && hops < 64) { x = x->VpiParent(); ++hops; }
      ps += "^" + std::string(UHDM::UhdmName(x->UhdmType())) + "#" + std::to_string(hops);
    }
    const UHDM::any* a = r->Actual_typespec();
    const char* fn = vpi_get_str(vpiFullName, h);
    std::cout << ps << "\t" << (a ? tn(a) + "@" + sp(a) : "-") << "\t[" << (fn ? fn : "") << "]\t" << ctx << "\n";
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
