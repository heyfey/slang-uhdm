#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <set>
#include <string>
#include <vector>
using namespace UHDM;
static std::string base(std::string_view p){size_t i=p.find_last_of('/');return std::string(i==std::string_view::npos?p:p.substr(i+1));}
static std::string ident(const BaseClass* o){
    if(!o) return "<null>"; char b[512]; std::string imp;
    if(o->UhdmType()==uhdmparameter) imp=std::string(((parameter*)o)->VpiImported());
    snprintf(b,sizeof b,"%s(%s)#%u imp=[%s] @%s:%u:%u",UhdmName(o->UhdmType()),
        std::string(o->VpiName()).c_str(),o->UhdmId(),imp.c_str(),
        base(o->VpiFile()).c_str(),o->VpiLineNo(),(unsigned)o->VpiColumnNo());
    return b;
}
int main(int argc,char** argv){
    Serializer s; auto restored=s.Restore(std::string(argv[1]));
    design* d=nullptr;
    for(auto h:restored){auto* o=(const BaseClass*)((const uhdm_handle*)h)->object; if(o->UhdmType()==uhdmdesign) d=(design*)o;}
    std::vector<const package*> pk;
    if(auto* v=d->AllPackages()) for(auto* p:*v) pk.push_back(p);
    if(auto* v=d->TopPackages()) for(auto* p:*v) pk.push_back(p);
    for(auto* p:pk){
        auto* ps=p->Parameters(); auto* pas=p->Param_assigns();
        size_t np=ps?ps->size():0, na=pas?pas->size():0;
        size_t in=0,out=0;
        std::set<const BaseClass*> pset; if(ps) pset.insert(ps->begin(),ps->end());
        if(pas) for(auto* pa:*pas){ if(pa->Lhs()&&pset.count(pa->Lhs())) in++; else out++; }
        printf("PKG %-16s #%u params=%zu pas=%zu LhsIN=%zu LhsOUT=%zu\n",
               std::string(p->VpiName()).c_str(), p->UhdmId(), np, na, in, out);
        if(pas&&out) { size_t i=0; for(auto* pa:*pas){ printf("   A[%zu] pa#%u parent=%s lhs=%s\n", i++, pa->UhdmId(), pa->VpiParent()?ident(pa->VpiParent()).c_str():"-", ident(pa->Lhs()).c_str()); if(i>3) break; } }
    }
    return 0;
}
