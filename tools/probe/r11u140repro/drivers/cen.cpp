// cen: census of listener-walk objects by mode (measurement only, r11u140).
//   unarysys : every unary operation whose parent is a sys_func_call:
//              sys name, op type, span, walk context (4 ancestors)
//   opctx <T>: every object of UHDM type name T: span, file, stored full name, ctx
#include <uhdm/Serializer.h>
#include <uhdm/VpiListener.h>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_visitor.h>
#include <iostream>
#include <memory>
#include <string>
#include <vector>
namespace {
std::string mode, arg;
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
  std::string ctx(int k) {
    std::string c;
    for (int i = (int)callstack.size() - 1, n = 0; i >= 0 && n < k; --i, ++n)
      c += std::string(n ? "<" : "") + tn(callstack[i]);
    return c;
  }
  void enterAny(const UHDM::any* o, vpiHandle h) override {
    if (mode == "unarysys") {
      if (o->UhdmType() != UHDM::uhdmoperation) return;
      auto* op = (const UHDM::operation*)o;
      auto* p = o->VpiParent();
      if (!p || p->UhdmType() != UHDM::uhdmsys_func_call) return;
      if (!op->Operands() || op->Operands()->size() != 1) return;
      std::cout << "U\t" << p->VpiName() << "\t" << op->VpiOpType() << "\t" << sp(o) << "\tw="
                << (o->VpiEndColumnNo() - o->VpiColumnNo()) << "\t" << ctx(6) << "\n";
    } else if (mode == "opctx") {
      if (UHDM::UhdmName(o->UhdmType()) != arg) return;
      vpiHandle eh = NewVpiHandle(o);
      const char* fn = vpi_get_str(vpiFullName, eh);
      vpi_free_object(eh);
      std::cout << tn(o) << "\t" << sp(o) << "\t[" << o->VpiFile() << "]\t{" << (fn ? fn : "") << "}\t" << ctx(6) << "\n";
    }
  }
};
}  // namespace
int main(int argc, char** argv) {
  if (argc < 3) return 3;
  mode = argv[2]; if (argc > 3) arg = argv[3];
  auto ser = std::make_unique<UHDM::Serializer>();
  std::vector<vpiHandle> h = ser->Restore(std::string(argv[1]));
  L l;
  l.listenDesigns(h);
  return 0;
}
