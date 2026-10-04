// (r11u232) objid: build with drivers/cc_objid.sh; reads one .uhdm given on the command line (the callers check the fence).
// objid: every reachable object of a .uhdm, by UhdmId:
// id type name fullname span P=<parent id> [A=<actual id>] [T=<typespec id>] [I=<instance id>]
#include <uhdm/uhdm.h>
#include <uhdm/Serializer.h>
#include <uhdm/UhdmListener.h>
#include <uhdm/vpi_visitor.h>
#include <iostream>
#include <map>
using namespace UHDM;
struct L : UhdmListener {
  std::map<uint32_t, const any*> objs;
  void enterAny(const any* const o) override { objs[o->UhdmId()] = o; }
};
int main(int argc, char** argv) {
  if (argc < 2) { std::cerr << "usage: objid db.uhdm\n"; return 2; }
  Serializer s;
  auto h = s.Restore(std::string(argv[1]));
  if (h.empty()) return 3;
  L l;
  for (auto d : h) l.listenDesign((const design*)((const uhdm_handle*)d)->object);
  auto idOf = [](const BaseClass* o) -> long { return o ? (long)o->UhdmId() : -1; };
  for (auto& [i, o] : l.objs) {
    vpiHandle vh = NewVpiHandle(o);
    const char* fn = vpi_get_str(vpiFullName, vh);
    std::cout << i << '\t' << UhdmName(o->UhdmType()) << '\t' << o->VpiName() << '\t' << (fn ? fn : "") << '\t'
              << o->VpiLineNo() << ':' << o->VpiColumnNo() << '-' << o->VpiEndLineNo() << ':' << o->VpiEndColumnNo()
              << "\tP=" << idOf(o->VpiParent());
    if (vpiHandle a = vpi_handle(vpiActual, vh)) { std::cout << "\tA=" << idOf((const BaseClass*)((uhdm_handle*)a)->object); vpi_release_handle(a); }
    if (vpiHandle t = vpi_handle(vpiTypespec, vh)) { std::cout << "\tT=" << idOf((const BaseClass*)((uhdm_handle*)t)->object); vpi_release_handle(t); }
    if (vpiHandle t = vpi_handle(vpiInstance, vh)) { std::cout << "\tI=" << idOf((const BaseClass*)((uhdm_handle*)t)->object); vpi_release_handle(t); }
    if (o->UhdmType() == uhdmtagged_pattern)
      std::cout << "\tPAT=" << idOf(((const tagged_pattern*)o)->Pattern());
    if (o->UhdmType() == uhdmio_decl)
      std::cout << "\tT=" << idOf(((const io_decl*)o)->Typespec());
    if (o->UhdmType() == uhdmparam_assign) {
      auto* pa = (const param_assign*)o;
      std::cout << "\tL=" << idOf(pa->Lhs()) << "\tR=" << idOf(pa->Rhs());
    }
    if (o->UhdmType() == uhdmpackage || o->UhdmType() == uhdmmodule_inst)
      std::cout << "\tTOP=" << vpi_get(vpiTop, vh);
    if (o->UhdmType() == uhdmtypespec_member) {
      auto* tm = (const typespec_member*)o;
      std::cout << "\tDV=" << idOf(tm->Default_value()) << "\tAV=" << idOf(tm->Actual_value());
    }
    std::cout << '\n';
    vpi_release_handle(vh);
  }
}
