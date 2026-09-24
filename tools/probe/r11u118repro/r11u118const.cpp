// r11u118 — constant/select field printer. MEASUREMENT ONLY.
// Prints every constant (and part_select/indexed_part_select/bit_select/ref_obj
// with a "::" name) with the fields the uhdm2rtlil plugin reads but uhdm-cmp
// never compares: VpiValue, VpiSize, VpiConstType, VpiFullName, VpiFile.
// usage: r11u118const <file.uhdm>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <iostream>
#include <string>
using namespace UHDM;
static std::string sp(const any* o) {
  if (!o) return "-";
  return std::to_string(o->VpiLineNo()) + ":" + std::to_string(o->VpiColumnNo()) + "-" +
         std::to_string(o->VpiEndLineNo()) + ":" + std::to_string(o->VpiEndColumnNo());
}
static std::string base(std::string_view f) {
  auto p = f.rfind('/');
  return std::string(p == std::string_view::npos ? f : f.substr(p + 1));
}
int main(int argc, char** argv) {
  Serializer s;
  if (s.Restore(std::string(argv[1])).empty()) { std::cerr << "restore failed\n"; return 2; }
  for (auto& kv : s.AllObjects()) {
    const any* o = kv.first;
    const any* p = o->VpiParent();
    std::string pk = p ? std::string(UhdmName(p->UhdmType())) + "#" + std::to_string(p->UhdmId()) : "NULL";
    if (o->UhdmType() == uhdmparameter) {
      auto pr = any_cast<const parameter*>(o);
      const any* pp = p ? p->VpiParent() : nullptr;
      std::cout << "parameter#" << o->UhdmId() << " " << sp(o) << " name='" << o->VpiName() << "' full='" << pr->VpiFullName()
                << "' parent=" << pk << " grandparent=" << (pp ? std::string(UhdmName(pp->UhdmType())) + ":" + std::string(pp->VpiName()) : "NULL")
                << " expr=" << (pr->Expr() ? UhdmName(pr->Expr()->UhdmType()) : "NULL") << "\n";
      continue;
    }
    if (o->UhdmType() == uhdmcont_assign) {
      auto ca = any_cast<const cont_assign*>(o);
      std::cout << "cont_assign#" << o->UhdmId() << " " << sp(o) << " parent=" << pk
                << " lhs=" << (ca->Lhs() ? std::string(UhdmName(ca->Lhs()->UhdmType())) + "#" + std::to_string(ca->Lhs()->UhdmId()) : "NULL")
                << " rhs=" << (ca->Rhs() ? std::string(UhdmName(ca->Rhs()->UhdmType())) + "#" + std::to_string(ca->Rhs()->UhdmId()) : "NULL") << "\n";
      continue;
    }
    if (auto c = any_cast<const constant*>(o)) {
      if (o->UhdmType() != uhdmconstant) continue;
      std::cout << "constant#" << o->UhdmId() << " " << sp(o) << " file=" << base(o->VpiFile())
                << " val='" << c->VpiValue() << "' size=" << c->VpiSize() << " ctype=" << c->VpiConstType()
                << " dec='" << c->VpiDecompile() << "' parent=" << pk << "\n";
    } else if (o->UhdmType() == uhdmpart_select || o->UhdmType() == uhdmindexed_part_select ||
               o->UhdmType() == uhdmbit_select || o->UhdmType() == uhdmref_obj || o->UhdmType() == uhdmvar_select) {
      const expr* e = any_cast<const expr*>(o);
      std::string fn;
      if (o->UhdmType() == uhdmref_obj) fn = std::string(any_cast<const ref_obj*>(o)->VpiFullName());
      if (o->UhdmType() == uhdmpart_select) fn = std::string(any_cast<const part_select*>(o)->VpiFullName());
      if (o->UhdmType() == uhdmindexed_part_select) fn = std::string(any_cast<const indexed_part_select*>(o)->VpiFullName());
      if (o->UhdmType() == uhdmbit_select) fn = std::string(any_cast<const bit_select*>(o)->VpiFullName());
      if (o->UhdmType() == uhdmvar_select) fn = std::string(any_cast<const var_select*>(o)->VpiFullName());
      std::cout << UhdmName(o->UhdmType()) << "#" << o->UhdmId() << " " << sp(o) << " file=" << base(o->VpiFile())
                << " name='" << o->VpiName() << "' def='" << o->VpiDefName() << "' full='" << fn
                << "' dec='" << (e ? e->VpiDecompile() : "") << "' parent=" << pk << "\n";
    }
  }
  return 0;
}
