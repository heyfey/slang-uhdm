// r10earl75 — rtfn75: print EVERY field ref_typespec::Compare reads (VpiName,
// VpiDefName, Actual_typespec) plus the COMPARE-INVISIBLE VpiFullName, for the
// head constant of flash_phy_core.sv:190:27, straight out of a .uhdm.
// MEASUREMENT ONLY.  Earlgrey uhdm-dump is >1 GB and is never produced.
//   build: g++ -O2 -std=c++17 rtfn75.cpp -I ~/.local/include \
//              -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o rtfn75
//   usage: rtfn75 <db.uhdm>
#include <uhdm/uhdm.h>
#include <uhdm/UhdmListener.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <string>
using namespace UHDM;
struct L : public UhdmListener {
  void enterConstant(const constant* const c) final {
    if (c->VpiLineNo() != 190 || c->VpiColumnNo() != 27) return;
    auto* rt = c->Typespec(); if (!rt) return;
    printf("const 190:27 rt.VpiName='%s' rt.VpiDefName='%s' rt.VpiFullName='%s' actual=%s@%u:%u\n",
      std::string(rt->VpiName()).c_str(), std::string(rt->VpiDefName()).c_str(),
      std::string(rt->VpiFullName()).c_str(),
      rt->Actual_typespec()? UhdmName(rt->Actual_typespec()->UhdmType()).data():"-",
      rt->Actual_typespec()? rt->Actual_typespec()->VpiLineNo():0,
      rt->Actual_typespec()? rt->Actual_typespec()->VpiColumnNo():0);
  }
};
int main(int c, char** v){ Serializer s; auto r=s.Restore(std::string(v[1])); L l;
  for (auto h:r){ auto*o=(const any*)((const uhdm_handle*)h)->object;
    if (auto*d=any_cast<const design*>(o)) l.listenDesign(d);} return 0;}
