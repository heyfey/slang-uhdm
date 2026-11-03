// pred472 <db>...: predicts the byte movers of § grpOwnOobGenericCls472 (F2) and
// § clsImpGroupHomeOrder472 (F1) from a PRISTINE database. Prints "<db> F1=<n> F2=<n> <details>".
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <iostream>
#include <map>
#include <set>
using namespace UHDM;
int main(int argc,char**argv){
  for(int ai=1; ai<argc; ai++){
    Serializer s; std::vector<vpiHandle> h;
    try { h=s.Restore(std::filesystem::path(argv[ai])); } catch(...) { std::cout<<argv[ai]<<" ERR\n"; continue; }
    if(h.empty()){ std::cout<<argv[ai]<<" EMPTY\n"; continue; }
    auto*d=(design*)((uhdm_handle*)h[0])->object;
    std::vector<const package*> pk;
    if(d->AllPackages()) for(auto*p:*d->AllPackages()) pk.push_back(p);
    if(d->TopPackages()) for(auto*p:*d->TopPackages()) pk.push_back(p);
    // imported package names anywhere
    std::set<std::string> importedNames;
    auto scanImp=[&](const VectorOftypespec* v){ if(v) for(auto*t:*v) if(t&&t->UhdmType()==uhdmimport_typespec) importedNames.insert(std::string(t->VpiName()));};
    for(auto*p:pk) scanImp(p->Typespecs());
    if(d->AllModules()) for(auto*m:*d->AllModules()) scanImp(m->Typespecs());
    if(d->TopModules()) for(auto*m:*d->TopModules()) scanImp(m->Typespecs());
    if(d->AllInterfaces()) for(auto*m:*d->AllInterfaces()) scanImp(m->Typespecs());
    scanImp(d->Typespecs());
    // F2
    int f2=0; std::string det;
    std::set<std::string> f2pk;
    for(auto*p:pk){
      bool cloneBearing=false; if(p->Typespecs()) for(auto*t:*p->Typespecs()) if(t&&t->UhdmType()==uhdmimport_typespec) cloneBearing=true;
      if(!cloneBearing||!p->Task_funcs()) continue;
      std::map<std::string,const class_defn*> cls; for(auto*p2:pk) if(p2->VpiName()==p->VpiName()&&p2->Class_defns()) for(auto*c:*p2->Class_defns()) cls[std::string(c->VpiName())]=c;
      for(auto*t:*p->Task_funcs()){ std::string n(t->VpiName()); auto k=n.find("::"); if(k==std::string::npos) continue; auto it=cls.find(n.substr(0,k)); if(it==cls.end()) continue;
        const class_defn* c=it->second; bool gen=false;
        if(c->Parameters()) for(auto*q:*c->Parameters()) if(q->VpiFile()==c->VpiFile() && q->VpiLineNo()>=c->VpiLineNo() && q->VpiLineNo()<=c->VpiEndLineNo()) gen=true;
        if(gen && importedNames.count(std::string(p->VpiName()))) { if(f2pk.insert(std::string(p->VpiName())+" "+n).second){ f2++; det+=" F2:"+std::string(p->VpiName())+"/"+n; } }
      }
    }
    // F1: class listing order vs each package's TOP listing order
    int f1=0;
    std::map<const task_func*,std::pair<const package*,size_t>> pos;
    if(d->TopPackages()) for(auto*p:*d->TopPackages()) if(p->Task_funcs()) for(size_t i=0;i<p->Task_funcs()->size();i++) pos.emplace((*p->Task_funcs())[i],std::make_pair(p,i));
    std::set<const class_defn*> seen;
    auto chk=[&](const VectorOfclass_defn* v){ if(!v) return; for(auto*c:*v){ if(!c||!seen.insert(c).second||!c->Task_funcs()) continue;
      std::map<const package*,size_t> last; bool bad=false;
      for(auto*t:*c->Task_funcs()){ auto it=pos.find(t); if(it==pos.end()) continue; if(t->VpiParent()!=it->second.first) continue; auto& l=last[it->second.first]; if(l>it->second.second+1 && l!=0) bad=true; l=it->second.second+1; }
      if(bad){ f1++; det+=" F1:"+std::string(c->VpiName()); } } };
    for(auto*p:pk) chk(p->Class_defns());
    if(d->AllModules()) for(auto*m:*d->AllModules()) chk(m->Class_defns());
    if(d->TopModules()) for(auto*m:*d->TopModules()) chk(m->Class_defns());
    chk(d->AllClasses());
    std::cout<<argv[ai]<<" F1="<<f1<<" F2="<<f2<<det.substr(0,400)<<"\n";
  }
}
