// r11u255 tfid.cpp: identity reader (build like r11u253repro/drivers/cc_x.sh with this source)
// tfid: for each class (all packages' class_defns + design AllClasses), print typespec ids, and each task_func io_decl's actual typespec id,
// so identity (shared typedef object vs copy) is visible. Fail-closed on $FENCED for the path argument.
#include <uhdm/uhdm.h>
#include <uhdm/Serializer.h>
#include <cstdlib>
#include <iostream>
#include <set>
#include <string>
using namespace UHDM;
static std::set<const any*> seen;
static void loc(const any* o){ std::cout << o->VpiLineNo() << ":" << o->VpiColumnNo(); }
static void doClass(const class_defn* c){
  if(!c || !seen.insert(c).second) return;
  std::cout << "CLASS " << c->VpiFullName() << " id=" << c->UhdmId() << "\n";
  if (c->Typespecs()) for (auto* t : *c->Typespecs()) { std::cout << "  TS " << t->VpiName() << " id=" << t->UhdmId() << " @"; loc(t); std::cout << "\n"; }
  if (c->Task_funcs()) for (auto* f : *c->Task_funcs()) {
    if (f->Io_decls()) for (auto* io : *f->Io_decls()) {
      const ref_typespec* r = io->Typespec(); const typespec* a = r ? r->Actual_typespec() : nullptr;
      std::cout << "  IO " << f->VpiName() << "." << io->VpiName() << " ref=" << (r? (int)r->UhdmId():-1);
      if (a) { std::cout << " actual=" << a->VpiName() << " id=" << a->UhdmId() << " @"; loc(a); const any* p=a->VpiParent(); if(p){ std::cout << " parent=" << UhdmName(p->UhdmType()) << ":" << p->VpiName() << "#" << p->UhdmId(); } }
      std::cout << "\n";
    }
  }
}
int main(int argc, char** argv){
  const char* f = std::getenv("FENCED"); if(!f||!*f){std::cerr<<"FENCED unset\n";return 4;}
  std::string p = argv[1]; std::string fs=f; size_t s=0; while(s<fs.size()){ size_t e=fs.find(' ',s); if(e==std::string::npos)e=fs.size(); std::string w=fs.substr(s,e-s); if(!w.empty() && p.find(w)!=std::string::npos){std::cerr<<"fenced\n";return 4;} s=e+1; }
  Serializer ser; auto v = ser.Restore(p);
  for (auto h : v) { const design* d = (const design*)((const uhdm_handle*)h)->object;
    if (d->AllPackages()) for (auto* pk : *d->AllPackages()) { std::cout << "PKG " << pk->VpiName() << " cls=" << (pk->Class_defns()?pk->Class_defns()->size():0) << "\n"; if (pk->Class_defns()) for (auto* c : *pk->Class_defns()) doClass(c); }
    if (d->TopPackages()) for (auto* pk : *d->TopPackages()) { std::cout << "TOPPKG " << pk->VpiName() << " cls=" << (pk->Class_defns()?pk->Class_defns()->size():0) << "\n"; if (pk->Class_defns()) for (auto* c : *pk->Class_defns()) doClass(c); }
    if (d->AllClasses()) for (auto* c : *d->AllClasses()) doClass(c);
  }
}
