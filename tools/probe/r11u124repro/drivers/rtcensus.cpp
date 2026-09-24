// rtcensus: every ref_typespec reached by the listener walk (raw, each once)
// with the object that holds it (walk parent), the holder's span and its
// own walk parent, the ref_typespec's vpiParent kind (NULL when unset), the
// full name vpi_get_str prints, and the actual typespec kind. Measurement
// only (r11u124).
#include <uhdm/Serializer.h>
#include <uhdm/VpiListener.h>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_visitor.h>
#include <iostream>
#include <memory>
#include <string>
#include <vector>
namespace {
std::string sp(const UHDM::BaseClass* o) {
  return std::to_string(o->VpiLineNo()) + ":" + std::to_string(o->VpiColumnNo()) + "-" +
         std::to_string(o->VpiEndLineNo()) + ":" + std::to_string(o->VpiEndColumnNo());
}
class L : public UHDM::VpiListener {
 public:
  void enterRef_typespec(const UHDM::ref_typespec* r, vpiHandle h) override {
    const UHDM::any* holder = callstack.size() >= 2 ? callstack[callstack.size() - 2] : nullptr;
    const UHDM::any* gh = callstack.size() >= 3 ? callstack[callstack.size() - 3] : nullptr;
    std::string fn;
    if (const char* s = vpi_get_str(vpiFullName, h)) fn = s;
    std::string par = r->VpiParent() ? UHDM::UhdmName(r->VpiParent()->UhdmType()) : "NULL";
    if (r->VpiParent() && r->VpiParent() == holder) par = "HOLDER";
    std::string scope = "-";
    for (int i = (int)callstack.size() - 2; i >= 0; --i) {
      auto t = callstack[i]->UhdmType();
      if (t == UHDM::uhdmpackage || t == UHDM::uhdmmodule_inst || t == UHDM::uhdminterface_inst ||
          t == UHDM::uhdmclass_defn || t == UHDM::uhdmgen_scope || t == UHDM::uhdmfunction || t == UHDM::uhdmtask) {
        scope = UHDM::UhdmName(t);
        if (t == UHDM::uhdmmodule_inst) scope += callstack[i]->VpiParent() && callstack[i]->VpiParent()->UhdmType() == UHDM::uhdmdesign && callstack[i]->VpiName().empty() ? ":def" : ":elab";
        break;
      }
    }
    std::string hk = holder ? UHDM::UhdmName(holder->UhdmType()) : "-";
    if (holder && holder->UhdmType() == UHDM::uhdmoperation)
      hk += ":" + std::to_string(((const UHDM::operation*)holder)->VpiOpType());
    std::cout << hk << "\t" << (holder ? sp(holder) : "") << "\t"
              << (gh ? UHDM::UhdmName(gh->UhdmType()) : "-") << "\t" << par << "\t" << fn << "\t"
              << (r->Actual_typespec() ? UHDM::UhdmName(r->Actual_typespec()->UhdmType()) : "none") << "\t" << scope << "\n";
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
