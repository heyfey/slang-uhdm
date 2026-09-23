// r11u111 -- CENSUS of the six faces' shapes (measurement only; uhdm-cmp is the judge).
// One line per cell, keyed by NAME / fullname (never ids), payload Compare-visible:
//   F1 <param fullname> <ts kind>(<ts name>) alias=<alias actual name|->     (params typed by a
//        pkg-named or pkg-aliased logic_typespec, every listing)
//   F2 <struct name>.<member> <member ts name> alias=<alias actual name|-> <alias actual parent kind>
//        (members of struct typespecs carried by a param_assign Rhs ref)
//   F3 <ALL|TOP> <pkg> <typedef name> elem=<elem actual name|-|none> ranges=<n>
//   F5 <ref_obj fullname> actual=<kind|->  (ref_objs inside a MODULE/INTERFACE param_assign Rhs)
//   F6 <type_parameter fullname> <ts kind>(<ts name>)
// build: g++ -O2 -std=c++17 cen111.cpp -I ~/.local/include -L ~/.local/lib64 -L ~/.local/lib \
//        -luhdm -lcapnp -lkj -o cen111
#include <uhdm/uhdm.h>
#include <uhdm/UhdmListener.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <filesystem>
#include <set>
#include <string>
using namespace UHDM;
static std::string nm(const any* o) { return o ? std::string(o->VpiName()) : std::string("-"); }
static std::string kn(const any* o) { return o ? std::string(UhdmName(o->UhdmType())) : std::string("-"); }
static const any* up(const any* o, UHDM_OBJECT_TYPE k) {
  for (auto* p = o ? o->VpiParent() : nullptr; p; p = p->VpiParent())
    if (p->UhdmType() == k) return p;
  return nullptr;
}
struct L : public UhdmListener {
  std::set<const any*> seen;
  void enterAny(const any* const o) override {
    if (!seen.insert(o).second) return;
    switch (o->UhdmType()) {
      case uhdmparameter: {
        auto* p = (const parameter*)o;
        auto* rt = p->Typespec();
        auto* ts = rt ? rt->Actual_typespec() : nullptr;
        if (!ts || ts->UhdmType() != uhdmlogic_typespec) return;
        auto* al = ts->Typedef_alias() ? ts->Typedef_alias()->Actual_typespec() : nullptr;
        std::string n = nm(ts), a = nm(al);
        if (n.find("::") == std::string::npos && a.find("::") == std::string::npos) return;
        printf("F1 %s %s(%s) alias=%s\n", std::string(p->VpiFullName()).c_str(), kn(ts).c_str(),
               n.c_str(), al ? a.c_str() : "-");
        return;
      }
      case uhdmparam_assign: {
        auto* pa = (const param_assign*)o;
        auto* r = pa->Rhs();
        if (!r || (r->UhdmType() != uhdmconstant && r->UhdmType() != uhdmoperation)) return;
        auto* rt = ((const expr*)r)->Typespec();
        auto* ts = rt ? rt->Actual_typespec() : nullptr;
        if (!ts || ts->UhdmType() != uhdmstruct_typespec) return;
        auto* ms = ((const struct_typespec*)ts)->Members();
        if (!ms) return;
        for (auto* m : *ms) {
          auto* mt = m->Typespec() ? m->Typespec()->Actual_typespec() : nullptr;
          if (!mt) continue;
          auto* al = mt->Typedef_alias() ? mt->Typedef_alias()->Actual_typespec() : nullptr;
          printf("F2 %s.%s %s alias=%s %s\n", nm(ts).c_str(), nm(m).c_str(), nm(mt).c_str(),
                 al ? nm(al).c_str() : "-", al ? kn(al->VpiParent()).c_str() : "-");
        }
        return;
      }
      case uhdmpackage: {
        auto* pk = (const package*)o;
        if (!pk->Typespecs()) return;
        for (auto* t : *pk->Typespecs()) {
          if (t->UhdmType() != uhdmlogic_typespec) continue;
          auto* lt = (const logic_typespec*)t;
          auto* e = lt->Elem_typespec();
          printf("F3 %s %s %s elem=%s ranges=%d\n", pk->VpiTop() ? "TOP" : "ALL", nm(pk).c_str(),
                 nm(t).c_str(), e ? (e->Actual_typespec() ? nm(e->Actual_typespec()).c_str() : "-") : "none",
                 lt->Ranges() ? (int)lt->Ranges()->size() : 0);
        }
        return;
      }
      case uhdmref_obj: {
        auto* pa = up(o, uhdmparam_assign);
        if (!pa) return;
        auto* inst = pa->VpiParent();
        if (!inst || (inst->UhdmType() != uhdmmodule_inst && inst->UhdmType() != uhdminterface_inst)) return;
        auto* r = (const ref_obj*)o;
        printf("F5 %s actual=%s\n", std::string(r->VpiFullName()).c_str(), kn(r->Actual_group()).c_str());
        return;
      }
      case uhdmtype_parameter: {
        auto* tp = (const type_parameter*)o;
        auto* ts = tp->Typespec() ? tp->Typespec()->Actual_typespec() : nullptr;
        printf("F6 %s %s(%s)\n", std::string(tp->VpiFullName()).c_str(), kn(ts).c_str(), nm(ts).c_str());
        return;
      }
      default:
        return;
    }
  }
};
int main(int argc, char** argv) {
  Serializer s;
  auto hs = s.Restore(std::filesystem::path(argv[1]));
  L l;
  for (auto h : hs) {
    auto* d = (const design*)((uhdm_handle*)h)->object;
    if (d->UhdmType() != uhdmdesign) continue;
    if (d->AllPackages()) for (auto* m : *d->AllPackages()) l.listenAny(m);
    if (d->TopPackages()) for (auto* m : *d->TopPackages()) l.listenAny(m);
    if (d->AllModules()) for (auto* m : *d->AllModules()) l.listenAny(m);
    if (d->TopModules()) for (auto* m : *d->TopModules()) l.listenAny(m);
  }
  return 0;
}
