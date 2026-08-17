#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <functional>
#include <set>
#include <string>
#include <vector>
using namespace UHDM;
static std::string base(std::string_view p){size_t i=p.find_last_of('/');return std::string(i==std::string_view::npos?p:p.substr(i+1));}
static std::string ident(const BaseClass* o){
    if(!o) return "<null>";
    char b[512];
    std::string imp;
    if(o->UhdmType()==uhdmparameter) imp = std::string(((parameter*)o)->VpiImported());
    snprintf(b,sizeof b,"%s(%s)#%u imp=[%s] @%s:%u:%u",UhdmName(o->UhdmType()),
             std::string(o->VpiName()).c_str(), o->UhdmId(), imp.c_str(),
             base(o->VpiFile()).c_str(), o->VpiLineNo(), (unsigned)o->VpiColumnNo());
    return b;
}
int main(int argc,char** argv){
    Serializer s; auto restored=s.Restore(std::string(argv[1]));
    design* d=nullptr;
    for(auto h:restored){auto* o=(const BaseClass*)((const uhdm_handle*)h)->object; if(o->UhdmType()==uhdmdesign) d=(design*)o;}
    std::string want = argc>2?argv[2]:"adpcm_driver";
    std::set<const class_defn*> seen; std::vector<const class_defn*> all;
    std::function<void(const class_defn*)> add=[&](const class_defn* c){
        if(!c||!seen.insert(c).second) return; all.push_back(c);
        if(auto* ts=c->Class_typespecs()) for(auto* t:*ts) if(t) add(t->Class_defn());
        if(auto* dv=c->Deriveds()) for(auto* t:*dv) add(t);
    };
    if(auto* v=d->AllClasses()) for(auto* c:*v) add(c);
    if(auto* v=d->AllPackages()) for(auto* p:*v) if(auto* cs=p->Class_defns()) for(auto* c:*cs) add(c);
    if(auto* v=d->TopPackages()) for(auto* p:*v) if(auto* cs=p->Class_defns()) for(auto* c:*cs) add(c);
    for(auto* c:all){
        if(std::string(c->VpiName())!=want) continue;
        printf("=== class %s #%u\n", want.c_str(), c->UhdmId());
        if(auto* ps=c->Parameters()){ size_t i=0; for(auto* p:*ps){ printf("  P[%2zu] %s  parent=%s\n", i++, ident(p).c_str(), p->VpiParent()?ident(p->VpiParent()).c_str():"-"); if(i>6) break; } }
        if(auto* pas=c->Param_assigns()){ size_t i=0; for(auto* pa:*pas){ printf("  A[%2zu] pa#%u lhs=%s parent=%s\n", i++, pa->UhdmId(), ident(pa->Lhs()).c_str(), pa->Lhs()&&pa->Lhs()->VpiParent()?ident(pa->Lhs()->VpiParent()).c_str():"-"); if(i>6) break; } }
    }
    return 0;
}
