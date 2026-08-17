// r10uvm83 — MEASUREMENT-ONLY.  uhdm-cmp remains the sole judge.
//
// THE HEAD PATH TRACER.  uhdm-cmp prints m_failedLhs / m_failedRhs and nothing
// else.  When the head is a big container with `RHS: <null>` those two pointers
// do not say which FIELD of which OWNER held the failing edge — and that owner
// is the thing a fix has to change.  This tool walks `design::Compare`'s own
// field order (table = r10ladder1repro/ctfields.inc, scraped from UHDM's
// generated Compare bodies) one level at a time:
//
//   * a level is walked with ONE CompareContext, exactly as the real Compare
//     body does, so `m_visited` is populated by the equal siblings before the
//     failing field is reached (208 of UHDM's 231 concrete kinds open with
//     `m_visited.insert(this)`; the 23 without are abstract bases);
//   * the visited set is SNAPSHOT immediately before each field and before each
//     vector element, so the tool can descend into the failing child from
//     exactly the state the real walk had;
//   * children are compared with UHDM's OWN `Compare` (never a re-implementation),
//     so the verdict at every step is the official one;
//   * and every step ASSERTS that the failure it descends into still reproduces
//     the OFFICIAL (m_failedLhs, m_failedRhs) pair.  A step that does not
//     reproduce it is printed as UNCONFIRMED and the descent stops: a path that
//     leads somewhere else is not the head's path.
//
//   usage: ct83path <golden.uhdm> <ours.uhdm> [maxdepth]
//
// build: g++ -O2 -std=c++17 ct83path.cpp -I ~/.local/include -I ../r10ladder1repro \
//        -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct83path
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <cstdlib>
#include <cstring>
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
  char b[320];
  snprintf(b,sizeof b,"%s(%s)#%u@%s:%u:%u-%u:%u",std::string(UhdmName(o->UhdmType())).c_str(),
           std::string(o->VpiName()).c_str(),o->UhdmId(),base(o->VpiFile()).c_str(),
           o->VpiLineNo(),(unsigned)o->VpiColumnNo(),o->VpiEndLineNo(),(unsigned)o->VpiEndColumnNo());
  return b;
}
// LOCAL, VERBATIM re-implementation of UHDM::BaseClass::SafeCompare
// (installed BaseClass.h lines 187-225); it is `protected` there.  The BRANCHES
// matter: only two of them set m_failedLhs WITHOUT m_failedRhs, and those two are
// the only way a head can print `RHS: <null>`.
static int32_t mySafe(const BaseClass* l,const BaseClass* r,CompareContext* c){
  if(l&&r) return l->Compare(r,c);
  if(l&&!r){ c->m_failedLhs=l; return 1; }
  if(!l&&r){ c->m_failedRhs=r; return -1; }
  return 0;
}

// The 24 fields UHDM exposes NO vpi selector for.  ctladder pays for these by
// hand and so must this tool: a skipped field is a field whose disagreement is
// invisible, and `design::AllPackages` — the very first container
// `design::Compare` walks — is one of them.
static bool fallbackVecPtr(const BaseClass* o,const char* f,std::vector<const BaseClass*>& out,bool& present){
  present=false;
  auto take=[&](auto* v){ present = v!=nullptr; if(v) for(auto* e:*v) out.push_back((const BaseClass*)e); return true; };
  if(auto* d=any_cast<const design*>((const any*)o)){
    if(!strcmp(f,"AllPackages")) return take(d->AllPackages());
    if(!strcmp(f,"TopPackages")) return take(d->TopPackages());
    if(!strcmp(f,"AllClasses")) return take(d->AllClasses());
    if(!strcmp(f,"AllInterfaces")) return take(d->AllInterfaces());
    if(!strcmp(f,"AllUdps")) return take(d->AllUdps());
    if(!strcmp(f,"AllPrograms")) return take(d->AllPrograms());
    if(!strcmp(f,"AllModules")) return take(d->AllModules());
    if(!strcmp(f,"TopModules")) return take(d->TopModules());
  }
  if(auto* i=any_cast<const instance*>((const any*)o))
    if(!strcmp(f,"Array_nets")) return take(i->Array_nets());
  if(auto* fs=any_cast<const for_stmt*>((const any*)o)){
    if(!strcmp(f,"VpiForInitStmts")) return take(fs->VpiForInitStmts());
    if(!strcmp(f,"VpiForIncStmts")) return take(fs->VpiForIncStmts());
  }
  if(auto* m=any_cast<const module_inst*>((const any*)o))
    if(!strcmp(f,"Module_arrays")) return take(m->Module_arrays());
  if(auto* vb=any_cast<const var_bit*>((const any*)o))
    if(!strcmp(f,"Expr_indexes")) return take(vb->Expr_indexes());
  if(auto* vs=any_cast<const var_select*>((const any*)o))
    if(!strcmp(f,"Exprs")) return take(vs->Exprs());
  return false;
}
static bool fallbackRel1(const BaseClass* o,const char* f,const BaseClass*& out){
  if(auto* tm=any_cast<const typespec_member*>((const any*)o))
    if(!strcmp(f,"Default_value")){ out=tm->Default_value(); return true; }
  return false;
}
typedef std::vector<const any*> Snap;
static void snapshot(const CompareContext& c,Snap& s){ s.assign(c.m_visited.begin(),c.m_visited.end()); }
static void seed(CompareContext& c,const Snap& s){ for(auto* p:s) c.m_visited.insert(p); }
static design* getdesign(Serializer& s,const char* p){
  auto restored=s.Restore(std::string(p));
  for(auto h:restored){auto* o=(BaseClass*)((const uhdm_handle*)h)->object; if(o->UhdmType()==uhdmdesign) return (design*)o;}
  return nullptr;
}
static const BaseClass* HL=nullptr; static const BaseClass* HR=nullptr;
int main(int argc,char** argv){
  if(argc<3){printf("usage: ct83path <golden> <ours> [maxdepth]\n");return 2;}
  int maxd = argc>3? atoi(argv[3]) : 40;
  Serializer sg,so;
  design* dg=getdesign(sg,argv[1]); design* dr=getdesign(so,argv[2]);
  if(!dg||!dr){printf("NO_DESIGN\n");return 2;}
  { CompareContext ctx; int32_t r=dg->Compare(dr,&ctx);
    printf("OFFICIAL r=%d visited=%zu\n  LHS %s\n  RHS %s\n",r,ctx.m_visited.size(),
           ident(ctx.m_failedLhs).c_str(),ident(ctx.m_failedRhs).c_str());
    if(r==0){printf("EQUAL\n");return 0;}
    HL=ctx.m_failedLhs; HR=ctx.m_failedRhs; }
  const BaseClass* L=dg; const BaseClass* R=dr; Snap S;
  for(int depth=0;depth<maxd;depth++){
    printf("\nLEVEL %d  G %s\n         O %s   (seed=%zu)\n",depth,ident(L).c_str(),ident(R).c_str(),S.size());
    auto it=kFields.find(std::string(UhdmName(L->UhdmType())));
    if(it==kFields.end()){ printf("  NO FIELD TABLE for kind %s — STOP\n",std::string(UhdmName(L->UhdmType())).c_str()); break; }
    CompareContext ctx; seed(ctx,S); ctx.m_visited.insert(L);
    bool moved=false;
    for(const Field& f:it->second){
      if(f.kind==F_TYPE){ if(L->VpiType()!=R->VpiType()){ printf("  PROP VpiType G=%d O=%d  <== HEAD FIELD\n",L->VpiType(),R->VpiType()); moved=false; goto done; } continue; }
      if(f.kind==F_PROP){
        if(!f.sel){ printf("  (field %s has no selector — not readable, skipped)\n",f.name); continue; }
        auto a=L->GetVpiPropertyValue(f.sel), b=R->GetVpiPropertyValue(f.sel);
        bool diff;
        if(std::holds_alternative<const char*>(a)!=std::holds_alternative<const char*>(b)) diff=true;
        else if(std::holds_alternative<const char*>(a)){
          const char* x=std::get<const char*>(a); const char* y=std::get<const char*>(b);
          diff = std::string(x?x:"")!=std::string(y?y:""); }
        else diff = std::get<int64_t>(a)!=std::get<int64_t>(b);
        if(diff){
          printf("  PROP %-22s DIFFERS  <== HEAD FIELD (owner G %s / O %s)\n",f.name,ident(L).c_str(),ident(R).c_str());
          if(std::holds_alternative<const char*>(a)) printf("       G=\"%s\" O=\"%s\"\n",std::get<const char*>(a)?:"" ,std::get<const char*>(b)?:"");
          else printf("       G=%lld O=%lld\n",(long long)std::get<int64_t>(a),(long long)std::get<int64_t>(b));
          goto done; }
        continue;
      }
      if(f.kind==F_REL1){
        const BaseClass* l=nullptr; const BaseClass* r=nullptr;
        if(f.sel){ l=std::get<0>(L->GetByVpiType(f.sel)); r=std::get<0>(R->GetByVpiType(f.sel)); }
        else if(!(fallbackRel1(L,f.name,l)&&fallbackRel1(R,f.name,r))){
          printf("  (rel1 %s has no selector and no fallback — NOT READ)\n",f.name); continue; }
        Snap pre; snapshot(ctx,pre);
        int32_t rr=mySafe(l,r,&ctx);
        if(rr==0) continue;
        printf("  REL1 %-22s FAILS r=%d\n       G %s\n       O %s\n",f.name,rr,ident(l).c_str(),ident(r).c_str());
        bool conf = (ctx.m_failedLhs==HL && ctx.m_failedRhs==HR);
        printf("       failedLhs=%s failedRhs=%s  %s\n",ident(ctx.m_failedLhs).c_str(),ident(ctx.m_failedRhs).c_str(),
               conf?"CONFIRMED == official head":"UNCONFIRMED");
        if(!l||!r){ printf("       *** THE HEAD: singular field %s is %s on our side; owner is\n       *** G %s\n       *** O %s\n",
                           f.name, r?"set but golden's is null":"NULL", ident(L).c_str(),ident(R).c_str()); goto done; }
        if(!conf){ printf("       descent stops (does not reproduce the official head)\n"); goto done; }
        L=l; R=r; S=pre; S.push_back(L); moved=true; break;
      }
      if(f.kind==F_RELV){
        std::vector<const BaseClass*> lvv,rvv; bool lp=false,rp=false; bool viafb=false;
        if(!f.sel){
          if(!(fallbackVecPtr(L,f.name,lvv,lp)&&fallbackVecPtr(R,f.name,rvv,rp))){
            printf("  (relv %s has no selector and no fallback — NOT READ)\n",f.name); continue; }
          viafb=true;
        } else {
          auto* a=std::get<2>(L->GetByVpiType(f.sel)); auto* b=std::get<2>(R->GetByVpiType(f.sel));
          lp=a!=nullptr; rp=b!=nullptr;
          if(a) for(auto* e:*a) lvv.push_back((const BaseClass*)e);
          if(b) for(auto* e:*b) rvv.push_back((const BaseClass*)e);
        }
        (void)viafb;
        const std::vector<const BaseClass*>* lv = lp? &lvv : nullptr;
        const std::vector<const BaseClass*>* rv = rp? &rvv : nullptr;
        if(lv&&rv){
          if(lv->size()!=rv->size()){
            printf("  RELV %-22s SIZE G=%zu O=%zu  <== HEAD FIELD (a MEMBERSHIP question)\n",f.name,lv->size(),rv->size());
            goto done; }
          bool br=false;
          for(size_t i=0;i<lv->size();i++){
            Snap pre; snapshot(ctx,pre);
            int32_t rr=mySafe(lv->at(i),rv->at(i),&ctx);
            if(rr==0) continue;
            printf("  RELV %-22s ELEM[%zu] FAILS r=%d\n       G %s\n       O %s\n",f.name,i,rr,
                   ident(lv->at(i)).c_str(),ident(rv->at(i)).c_str());
            bool conf=(ctx.m_failedLhs==HL && ctx.m_failedRhs==HR);
            printf("       failedLhs=%s failedRhs=%s  %s\n",ident(ctx.m_failedLhs).c_str(),ident(ctx.m_failedRhs).c_str(),
                   conf?"CONFIRMED == official head":"UNCONFIRMED");
            if(!lv->at(i)||!rv->at(i)){ printf("       *** THE HEAD: null ELEMENT\n"); goto done; }
            if(!conf){ printf("       descent stops (does not reproduce the official head)\n"); goto done; }
            L=lv->at(i); R=rv->at(i); S=pre; S.push_back(L); moved=true; br=true; break;
          }
          if(br) break;
        } else if(lv&&!lv->empty()&&!rv){
          printf("  RELV %-22s OURS-VECTOR-IS-NULL (G n=%zu)  <== HEAD FIELD\n",f.name,lv->size()); goto done;
        } else if(!lv&&rv&&!rv->empty()){
          printf("  RELV %-22s GOLDEN-VECTOR-IS-NULL (O n=%zu)  <== HEAD FIELD\n",f.name,rv->size()); goto done;
        }
        continue;
      }
    }
    if(!moved){ printf("  no failing field at this level — STOP\n"); break; }
  }
done:
  return 0;
}
