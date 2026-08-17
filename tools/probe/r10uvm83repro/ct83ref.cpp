// r10uvm83 — MEASUREMENT-ONLY.  uhdm-cmp remains the sole judge.
//
// THE REFERRER INDEX.  When uhdm-cmp's head is `LHS: <a container>  RHS: <null>`
// the failing call is one of the two `SafeCompare` branches that set ONLY
// m_failedLhs:
//    (1) SafeCompare(lhs_obj, non-empty vec, rhs_obj, NULL vec)   -> lhs_obj
//    (2) SafeCompare(lhs_child, rhs_child == nullptr)             -> lhs_child
// Branch (2) makes the head the CHILD, not its owner, so the head object tells
// you nothing about WHO was holding the pointer.  This tool finds every object
// in the golden database that points AT the head, together with the FIELD NAME
// of that edge (field table = r10ladder1repro/ctfields.inc, the official
// Compare field order), and then reads the SAME field on the matching object of
// OUR database, matched by kind+name+span+parent-chain.
//
//   usage: ct83ref <golden.uhdm> <ours.uhdm> <headUhdmId>
// build: g++ -O2 -std=c++17 ct83ref.cpp -I ~/.local/include \
//        -I ../r10ladder1repro -L ~/.local/lib64 -L ~/.local/lib \
//        -luhdm -lcapnp -lkj -o ct83ref
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <map>
#include <set>
#include <string>
#include <unordered_map>
#include <vector>
using namespace UHDM;
enum FKind { F_TYPE = 0, F_PROP = 1, F_REL1 = 2, F_RELV = 3 };
struct Field { const char* name; int sel; FKind kind; };
static const std::map<std::string, std::vector<Field>> kFields = {
#include "ctfields.inc"
};
static std::string base(std::string_view p){size_t i=p.find_last_of('/');return std::string(i==std::string_view::npos?p:p.substr(i+1));}
static std::string spanOf(const BaseClass* o){char b[192];snprintf(b,sizeof b,"%s:%u:%u-%u:%u",base(o->VpiFile()).c_str(),o->VpiLineNo(),(unsigned)o->VpiColumnNo(),o->VpiEndLineNo(),(unsigned)o->VpiEndColumnNo());return b;}
static std::string ident(const BaseClass* o){
  if(!o) return "<null>";
  std::string s=std::string(UhdmName(o->UhdmType()));
  if(!o->VpiName().empty()) s+="("+std::string(o->VpiName())+")";
  return s+"@"+spanOf(o)+"#"+std::to_string(o->UhdmId());
}
static std::string keyOf(const BaseClass* o,int n=6){
  std::string s; for(int i=0;i<n&&o;i++){ s+=(i?"<":"")+std::string(UhdmName(o->UhdmType()))+":"+std::string(o->VpiName())+":"+spanOf(o); o=o->VpiParent(); }
  return s;
}
static const BaseClass* rel1(const BaseClass* o,const Field& f){
  if(!f.sel) return nullptr;
  return std::get<0>(o->GetByVpiType(f.sel));
}
static void relv(const BaseClass* o,const Field& f,std::vector<const BaseClass*>& out){
  if(!f.sel) return;
  if(auto* v=std::get<2>(o->GetByVpiType(f.sel))) for(auto* e:*v) if(e) out.push_back((const BaseClass*)e);
}
int main(int argc,char** argv){
  if(argc<4){printf("usage: ct83ref <golden> <ours> <headId>\n");return 2;}
  unsigned want=(unsigned)strtoul(argv[3],nullptr,10);
  Serializer sg,so;
  sg.Restore(std::string(argv[1])); so.Restore(std::string(argv[2]));
  auto allg=sg.AllObjects(); auto allo=so.AllObjects();
  const BaseClass* head=nullptr;
  for(auto& kv:allg){ const BaseClass* o=(const BaseClass*)kv.first; if(o&&o->UhdmId()==want){head=o;break;} }
  if(!head){printf("HEAD ID %u NOT FOUND IN GOLDEN\n",want);return 2;}
  printf("HEAD %s\n",ident(head).c_str());
  // index OUR objects by key
  std::unordered_multimap<std::string,const BaseClass*> omap;
  for(auto& kv:allo){ const BaseClass* o=(const BaseClass*)kv.first; if(o) omap.emplace(keyOf(o),o); }
  size_t nref=0;
  for(auto& kv:allg){
    const BaseClass* X=(const BaseClass*)kv.first; if(!X) continue;
    auto it=kFields.find(std::string(UhdmName(X->UhdmType()))); if(it==kFields.end()) continue;
    for(const Field& f:it->second){
      bool hit=false; bool isvec=false; size_t idx=0;
      if(f.kind==F_REL1){ if(rel1(X,f)==head) hit=true; }
      else if(f.kind==F_RELV){ std::vector<const BaseClass*> v; relv(X,f,v);
        for(size_t i=0;i<v.size();i++) if(v[i]==head){hit=true;isvec=true;idx=i;break;} }
      if(!hit) continue;
      nref++;
      printf("REF %-22s %s  %s\n",f.name,isvec?("vec["+std::to_string(idx)+"]").c_str():"rel1",ident(X).c_str());
      // matching object on our side
      auto k=keyOf(X); auto rng=omap.equal_range(k);
      size_t nc=0; for(auto i2=rng.first;i2!=rng.second;++i2) nc++;
      if(nc==0){ printf("    OURS: NO COUNTERPART for key\n"); continue; }
      for(auto i2=rng.first;i2!=rng.second;++i2){
        const BaseClass* Y=i2->second;
        if(f.kind==F_REL1){
          const BaseClass* t=rel1(Y,f);
          printf("    OURS %s .%s = %s%s\n",ident(Y).c_str(),f.name,ident(t).c_str(),
                 t?"":"   <== NULL IN OURS, NON-NULL IN GOLDEN");
        } else {
          std::vector<const BaseClass*> v; relv(Y,f,v);
          printf("    OURS %s .%s n=%zu %s\n",ident(Y).c_str(),f.name,v.size(),
                 idx<v.size()?ident(v[idx]).c_str():"<index absent>");
        }
      }
    }
  }
  printf("REFERRERS=%zu\n",nref);
  return 0;
}
