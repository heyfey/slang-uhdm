// r10earl96 -- MEASUREMENT ONLY.  Every object whose VpiName (or the name of
// the typespec it points at) matches a substring, printed with the fields the
// generated Compares read, its parent chain, its Instance, and -- for a
// typespec -- every ref_typespec that names it as Actual_typespec and every
// scope whose Typespecs() list contains it.
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <string>
#include <vector>
#include <map>
#include <set>
#include <algorithm>
using namespace UHDM;
static std::string sp(const BaseClass*o){if(!o)return "-";char b[64];snprintf(b,sizeof b,"%u:%u-%u:%u",o->VpiLineNo(),o->VpiColumnNo(),o->VpiEndLineNo(),o->VpiEndColumnNo());return b;}
static std::string kn(const BaseClass*o){return o?std::string(UHDM::UhdmName(o->UhdmType())):std::string("<null>");}
static std::string nm(const BaseClass*o){if(!o)return "-";return std::string(((const any*)o)->VpiName());}
static std::string fn(const BaseClass*o){
  if(!o)return "-";
  if(const scope*sc=any_cast<const scope*>((const any*)o)) return std::string(sc->VpiFullName());
  if(const nets*n=any_cast<const nets*>((const any*)o)) return std::string(n->VpiFullName());
  if(const variables*v=any_cast<const variables*>((const any*)o)) return std::string(v->VpiFullName());
  if(const parameter*pa=any_cast<const parameter*>((const any*)o)) return std::string(pa->VpiFullName());
  if(const ref_typespec*rt=any_cast<const ref_typespec*>((const any*)o)) return std::string(rt->VpiFullName());
  if(const ref_obj*ro=any_cast<const ref_obj*>((const any*)o)) return std::string(ro->VpiFullName());
  if(const gen_scope_array*ga=any_cast<const gen_scope_array*>((const any*)o)) return std::string(ga->VpiFullName());
  return "-";
}
static std::string file(const BaseClass*o){if(!o)return "-";std::string f(o->VpiFile());size_t p=f.rfind('/');return p==std::string::npos?f:f.substr(p+1);}
static std::string chain(const BaseClass*o){
  std::string c; int n=0;
  for(const BaseClass*p=o?o->VpiParent():nullptr;p&&n<6;p=p->VpiParent(),++n){
    c += "<-" + kn(p) + "[" + nm(p) + "|" + fn(p) + "]";
  }
  return c.empty()?std::string("<-<null>"):c;
}
int main(int argc,char**argv){
  Serializer s; auto r=s.Restore(std::string(argv[1]));
  if(r.empty()){fprintf(stderr,"RESTORE_FAILED\n");return 3;}
  std::string pat = argc>2?argv[2]:"";
  // pass 1: collect matching typespecs
  std::set<const BaseClass*> hits;
  for(auto&pr:s.AllObjects()){
    const BaseClass*bo=pr.first; if(!bo) continue;
    std::string n = nm(bo);
    if(!pat.empty() && n.find(pat)==std::string::npos) continue;
    hits.insert(bo);
  }
  // pass 2: back-references
  std::map<const BaseClass*,std::vector<std::string>> refs;
  for(auto&pr:s.AllObjects()){
    const BaseClass*bo=pr.first; if(!bo) continue;
    if(bo->UhdmType()==uhdmref_typespec){
      const ref_typespec*rt=(const ref_typespec*)bo;
      const BaseClass*a=rt->Actual_typespec();
      if(a&&hits.count(a)) refs[a].push_back("REFBY ref_typespec id? name="+nm(rt)+" span="+sp(rt)+" par="+kn(rt->VpiParent())+"["+nm(rt->VpiParent())+"|"+fn(rt->VpiParent())+"]");
    }
  }
  std::vector<std::string> rows;
  for(const BaseClass*bo:hits){
    std::string extra;
    if(bo->UhdmType()==uhdmref_typespec){
      const ref_typespec*rt=(const ref_typespec*)bo;
      extra=" ACT="+kn(rt->Actual_typespec())+"("+nm(rt->Actual_typespec())+" "+sp(rt->Actual_typespec())+")";
    }
    const typespec* ts = any_cast<const typespec*>((const any*)bo);
    std::string inst = ts&&ts->Instance()? kn(ts->Instance())+"["+nm(ts->Instance())+"]" : std::string("-");
    std::string alias = ts&&ts->Typedef_alias()? kn(ts->Typedef_alias())+"["+nm(ts->Typedef_alias())+"]" : std::string("-");
    char b[8192];
    snprintf(b,sizeof b,"%-18s name=%-28s full=%-46s span=%-14s file=%-22s INST=%-24s ALIAS=%-20s%s PAR%s",
      kn(bo).c_str(), nm(bo).c_str(), fn(bo).c_str(), sp(bo).c_str(), file(bo).c_str(),
      inst.c_str(), alias.c_str(), extra.c_str(), chain(bo).c_str());
    std::string row=b;
    for(auto&x:refs[bo]) row += "\n      "+x;
    rows.push_back(row);
  }
  std::sort(rows.begin(),rows.end());
  for(auto&l:rows) printf("%s\n",l.c_str());
  printf("-- hits=%zu\n",hits.size());
  return 0;
}
