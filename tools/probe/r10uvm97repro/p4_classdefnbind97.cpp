#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <string>
#include <vector>
#include <algorithm>
using namespace UHDM;
static std::string fn(const BaseClass* p){ if(!p) return "-"; vpiHandle h=NewVpiHandle(p); const char* s=h?vpi_get_str(vpiFullName,h):nullptr; std::string r=s?s:std::string(p->VpiName()); if(h) vpi_free_object(h); if(r.empty()) r=std::string(p->VpiName()); return r.empty()?"<anon>":r; }
int main(int argc,char**argv){
  Serializer s; if(s.Restore(std::string(argv[1])).empty()){printf("RESTORE_FAILED\n");return 3;}
  std::vector<std::string> rows;
  for(auto&p:s.AllObjects()){
    const BaseClass*o=p.first; if(!o) continue;
    const ref_typespec* rt=nullptr;
    if(o->UhdmType()==uhdmio_decl) rt=((const io_decl*)o)->Typespec();
    else if(auto*v=any_cast<const variables*>(o)) rt=v->Typespec();
    else continue;
    const typespec* a=rt?rt->Actual_typespec():nullptr;
    if(!a||a->UhdmType()!=uhdmclass_typespec) continue;
    char b[600];
    snprintf(b,sizeof b,"%s\t%u:%u\t%s\t%s", fn(o).c_str(), o->VpiLineNo(), o->VpiColumnNo(),
      std::string(a->VpiName()).c_str(), fn(((const class_typespec*)a)->Class_defn()).c_str());
    rows.push_back(b);
  }
  std::sort(rows.begin(),rows.end()); rows.erase(std::unique(rows.begin(),rows.end()),rows.end());
  for(auto&x:rows) printf("%s\n",x.c_str());
  return 0;
}
