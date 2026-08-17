// r10uvm83 — MEASUREMENT-ONLY.  Prints EVERY compared field of the object with a
// given UhdmId, in the official Compare order (r10ladder1repro/ctfields.inc),
// so a single object can be read off both databases and compared by eye.
//   usage: ct83fld <db.uhdm> <uhdmId> [<uhdmId> ...]
// build: g++ -O2 -std=c++17 ct83fld.cpp -I ~/.local/include -I ../r10ladder1repro \
//        -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct83fld
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <cstdlib>
#include <map>
#include <string>
#include <vector>
using namespace UHDM;
enum FKind { F_TYPE = 0, F_PROP = 1, F_REL1 = 2, F_RELV = 3 };
struct Field { const char* name; int sel; FKind kind; };
static const std::map<std::string, std::vector<Field>> kFields = {
#include "ctfields.inc"
};
static std::string base(std::string_view p){size_t i=p.find_last_of('/');return std::string(i==std::string_view::npos?p:p.substr(i+1));}
static std::string ident(const BaseClass* o){
  if(!o) return "<null>";
  char b[256];
  snprintf(b,sizeof b,"%s(%s)#%u@%s:%u:%u-%u:%u",std::string(UhdmName(o->UhdmType())).c_str(),
           std::string(o->VpiName()).c_str(),o->UhdmId(),base(o->VpiFile()).c_str(),
           o->VpiLineNo(),(unsigned)o->VpiColumnNo(),o->VpiEndLineNo(),(unsigned)o->VpiEndColumnNo());
  return b;
}
int main(int argc,char** argv){
  if(argc<3){printf("usage: ct83fld <db> <id>...\n");return 2;}
  Serializer s; s.Restore(std::string(argv[1]));
  auto all=s.AllObjects();
  for(int i=2;i<argc;i++){
    unsigned want=(unsigned)strtoul(argv[i],nullptr,10);
    const BaseClass* o=nullptr;
    for(auto& kv:all){ const BaseClass* x=(const BaseClass*)kv.first; if(x&&x->UhdmId()==want){o=x;break;} }
    if(!o){ printf("== ID %u NOT FOUND\n",want); continue; }
    printf("== %s   parent=%s\n",ident(o).c_str(),ident(o->VpiParent()).c_str());
    auto it=kFields.find(std::string(UhdmName(o->UhdmType())));
    if(it==kFields.end()){ printf("   (no field table for this kind)\n"); continue; }
    for(const Field& f:it->second){
      if(f.kind==F_PROP||f.kind==F_TYPE){
        if(!f.sel){ printf("   %-24s <no selector>\n",f.name); continue; }
        auto pv=o->GetVpiPropertyValue(f.sel);
        if(std::holds_alternative<const char*>(pv)){ const char* p=std::get<const char*>(pv);
          printf("   %-24s \"%s\"\n",f.name,p?p:""); }
        else printf("   %-24s %lld\n",f.name,(long long)std::get<int64_t>(pv));
      } else if(f.kind==F_REL1){
        const BaseClass* t=f.sel?std::get<0>(o->GetByVpiType(f.sel)):nullptr;
        printf("   %-24s %s\n",f.name,ident(t).c_str());
      } else {
        auto* v=f.sel?std::get<2>(o->GetByVpiType(f.sel)):nullptr;
        printf("   %-24s %s\n",f.name,v?("n="+std::to_string(v->size())).c_str():"NULL");
      }
    }
  }
  return 0;
}
