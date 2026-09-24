// uhdm-parents: lists every object in listener walk order (the raw walk,
// as uhdm-strictcmp --no-canon) with its stored/computed full name, its
// span, file basename and its vpiParent chain (types and names, nearest
// first), plus whether the vpiParent is the walk parent (P=walk) or not.
// Measurement only (r11u124). Usage: uhdm-parents <db.uhdm> [grep-substring]
#include <uhdm/Serializer.h>
#include <uhdm/VpiListener.h>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_visitor.h>
#include <iostream>
#include <memory>
#include <string>
#include <vector>
namespace {
std::string chain(const UHDM::BaseClass* o) {
  std::string out;
  int n = 0;
  for (const UHDM::BaseClass* p = o->VpiParent(); p && n < 8; p = p->VpiParent(), ++n) {
    if (!out.empty()) out += "<";
    out += UHDM::UhdmName(p->UhdmType());
    if (!p->VpiName().empty()) out += "(" + std::string(p->VpiName()) + ")";
  }
  if (!o->VpiParent()) out = "<NULL>";
  return out;
}
class L : public UHDM::VpiListener {
 public:
  std::string filt;
  size_t idx = 0;
  void enterAny(const UHDM::any* o, vpiHandle h) override {
    const UHDM::any* walkParent = callstack.size() >= 2 ? callstack[callstack.size() - 2] : nullptr;
    std::string fn;
    if (const char* s = vpi_get_str(vpiFullName, h)) fn = s;
    std::string f(o->VpiFile());
    auto pos = f.find_last_of("/\\");
    if (pos != std::string::npos) f = f.substr(pos + 1);
    std::string line = "#" + std::to_string(idx++) + "\t" + std::to_string(callstack.size()) + "\t" +
                       UHDM::UhdmName(o->UhdmType()) + "\t" + std::string(o->VpiName()) + "\tfn=" + fn +
                       "\t" + f + " " + std::to_string(o->VpiLineNo()) + ":" + std::to_string(o->VpiColumnNo()) +
                       "-" + std::to_string(o->VpiEndLineNo()) + ":" + std::to_string(o->VpiEndColumnNo());
    if (const UHDM::expr* e = dynamic_cast<const UHDM::expr*>(o))
      line += "\tv=" + std::string(e->VpiValue()) + " d=" + std::string(e->VpiDecompile());
    line += "\t" + std::string(o->VpiParent() == walkParent ? "P=walk" : "P=other") + "\t^" + chain(o);
    if (filt.empty() || line.find(filt) != std::string::npos) std::cout << line << "\n";
  }
};
}  // namespace
int main(int argc, char** argv) {
  if (argc < 2) return 3;
  auto ser = std::make_unique<UHDM::Serializer>();
  std::vector<vpiHandle> h = ser->Restore(std::string(argv[1]));
  L l;
  if (argc > 2) l.filt = argv[2];
  l.listenDesigns(h);
  return 0;
}
