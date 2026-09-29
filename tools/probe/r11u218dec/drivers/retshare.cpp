// r11u218dec retshare: for every function listed in a package's task_funcs or a class_defn's methods of a UHDM
// database, print the listing, the function's full name and span, and an identity number of its vpiReturn
// variable (the first listing that holds the object numbers it), with the return variable's parent function's
// span: shows which listings share one return object. Build: g++ -std=c++17 -I$HOME/.local/include
// retshare.cpp -L$HOME/.local/lib64 -luhdm -lcapnp -lkj -lpthread -o retshare
#include <uhdm/uhdm.h>
#include <uhdm/Serializer.h>
#include <cstdio>
#include <map>
#include <string>
using namespace UHDM;
static std::map<const any*, int> ids;
static int idOf(const any* o) { auto it = ids.find(o); if (it != ids.end()) return it->second; int n = ids.size() + 1; ids[o] = n; return n; }
static void fn(const char* listing, const std::string& owner, const any* t) {
  if (!t || t->UhdmType() != uhdmfunction) return;
  auto* f = (const function*)t;
  const any* r = f->Return();
  const any* rp = r ? r->VpiParent() : nullptr;
  printf("%s\t%s\t%s\t%u:%u-%u:%u\tret#%d\tret_parent=%s %u:%u\n", listing, owner.c_str(), std::string(f->VpiFullName()).c_str(),
         f->VpiLineNo(), f->VpiColumnNo(), f->VpiEndLineNo(), f->VpiEndColumnNo(), r ? idOf(r) : 0,
         rp && rp->UhdmType() == uhdmfunction ? std::string(((const function*)rp)->VpiFullName()).c_str() : "-", rp ? rp->VpiLineNo() : 0, rp ? rp->VpiColumnNo() : 0);
}
static void pkg(const char* view, const package* p) {
  if (p->Task_funcs()) for (auto* t : *p->Task_funcs()) fn(view, std::string(p->VpiName()) + "/task_funcs", t);
  if (p->Class_defns()) for (auto* c : *p->Class_defns()) if (c->Task_funcs()) for (auto* m : *c->Task_funcs())
    fn(view, std::string(p->VpiName()) + "/" + std::string(c->VpiName()) + "/task_funcs", m);
}
int main(int argc, char** argv) {
  Serializer s; auto designs = s.Restore(std::string(argv[1]));
  for (auto* h : designs) {
    auto* d = (const design*)((const uhdm_handle*)h)->object;
    if (d->AllPackages()) for (auto* p : *d->AllPackages()) pkg("all", p);
    if (d->TopPackages()) for (auto* p : *d->TopPackages()) pkg("top", p);
  }
}
