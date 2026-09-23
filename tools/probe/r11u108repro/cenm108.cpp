// r11u108 -- CENSUS of the defPkgMemberTdOfNamedShares108 shape (measurement only).
// For every struct/union typespec PARENTED at a package of the DEF listing
// (design->AllPackages), prints one line per member:
//   <pkg>|<struct name>|<member> <typespec kind> name=<typespec name> elem=<elem name|->
// The law's golden shape is a member bound to a NAMED `pkg::T` logic_typespec.
// build: g++ -O2 -std=c++17 cenm108.cpp -I ~/.local/include -L ~/.local/lib64 \
//        -L ~/.local/lib -luhdm -lcapnp -lkj -o cenm108
#include <uhdm/uhdm.h>
#include <uhdm/UhdmListener.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <set>
#include <string>
using namespace UHDM;
struct L : public UhdmListener {
  std::string pkg;
  const any* pkgObj = nullptr;
  std::set<std::string> out;
  void enterAny(const any* const o) override {
    auto* tm = dynamic_cast<const typespec_member*>(o);
    if (!tm) return;
    auto* par = tm->VpiParent();
    // ONE POSITION ONLY: a member of a struct/union whose own parent is the
    // DEF package being listed (the listener also reaches TOP-listing and
    // module-side structs through shared objects; those are not this cell).
    if (!par || par->VpiParent() != pkgObj) return;
    std::string sn = std::string(par->VpiName());
    auto* rt = tm->Typespec();
    const typespec* ts = rt ? rt->Actual_typespec() : nullptr;
    std::string k = ts ? std::string(UhdmName(ts->UhdmType())) : "<null>";
    std::string n = ts ? std::string(ts->VpiName()) : "";
    std::string e = "-";
    if (ts && ts->UhdmType() == uhdmlogic_typespec)
      if (auto* er = ((const logic_typespec*)ts)->Elem_typespec())
        e = er->Actual_typespec() ? std::string(er->Actual_typespec()->VpiName()) : "<nullact>";
    out.insert(pkg + "|" + sn + "|" + std::string(tm->VpiName()) + " " + k + " name=" + n + " elem=" + e);
  }
};
int main(int argc, char** argv) {
  Serializer s;
  auto hs = s.Restore(std::string(argv[1]));
  // A FRESH listener per package: UhdmListener keeps its visited set across
  // listenAny calls, so one listener walked from the `builtin` package first
  // would mark a later package's structs visited and silently drop them.
  std::set<std::string> all;
  for (auto h : hs) {
    auto* d = (const design*)((uhdm_handle*)h)->object;
    if (d->UhdmType() != uhdmdesign || !d->AllPackages()) continue;
    for (auto* p : *d->AllPackages()) {
      L l; l.pkg = std::string(p->VpiName()); l.pkgObj = p; l.listenAny(p);
      all.insert(l.out.begin(), l.out.end());
    }
  }
  for (auto& x : all) printf("%s\n", x.c_str());
  return 0;
}
