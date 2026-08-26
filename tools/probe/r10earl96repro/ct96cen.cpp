// r10earl96 -- THE CORPUS CENSUS.  MEASUREMENT ONLY; the official uhdm-cmp is
// the sole judge.
//
// Three families, all keyed TOP-DOWN from a named root (module_inst /
// interface_inst / package) by the FIELD PATH the walk took -- never by
// vpiParent, because the two producers park these objects on different
// parents and no generated Compare reads VpiParent anyway.
//
//   TS  every typespec reachable from a root through Param_assigns (Lhs and
//       Rhs), Parameters, Nets, Variables and the root's own Typespecs
//       listing, following ref_typespec -> Actual_typespec, array/packed-array
//       Elem_typespec and typespec::Typedef_alias.  PAYLOAD = the kind, the
//       VpiName and the vpiInstance name -- the three fields typespec::Compare
//       and its subclasses actually read at this position.
//   AL  the ALIAS-CHAIN projection: one row per typespec that carries a
//       Typedef_alias, payload = own name -> alias target name.  This is the
//       family the law moves.
//   GA  the GLOBAL tripwire: every named typespec in the arena, keyed by kind
//       + span + name only, so a rename ANYWHERE (outside the walked paths
//       included) shows up as a bucket delta.
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <cstring>
#include <string>
#include <vector>
#include <set>
#include <map>
#include <algorithm>
using namespace UHDM;
static std::string kn(const BaseClass*o){return o?std::string(UHDM::UhdmName(o->UhdmType())):std::string("<null>");}
static std::string nmOf(const BaseClass*o){if(!o)return "-";std::string n(((const any*)o)->VpiName());return n.empty()?std::string("~"):n;}
static std::string sp(const BaseClass*o){if(!o)return "-";char b[64];snprintf(b,sizeof b,"%u:%u-%u:%u",o->VpiLineNo(),o->VpiColumnNo(),o->VpiEndLineNo(),o->VpiEndColumnNo());return b;}
static std::string full(const BaseClass*o){
  if(!o)return "-";
  if(const scope*sc=any_cast<const scope*>((const any*)o)) return std::string(sc->VpiFullName());
  return nmOf(o);
}
static std::vector<std::string> rows;

static void emitTs(const any* t, const std::string& root, const std::string& path, int d){
  if(!t||d>8) return;
  if(t->UhdmType()==uhdmref_typespec){
    emitTs(((const ref_typespec*)t)->Actual_typespec(), root, path+">r", d+1); return;
  }
  const typespec* ts = any_cast<const typespec*>(t);
  if(!ts) return;
  char b[3072];
  snprintf(b,sizeof b,"TS\t%s\t%s\t%s\t%s|%s|%s", root.c_str(), path.c_str(), sp(t).c_str(),
           kn(t).c_str(), nmOf(t).c_str(), ts->Instance()?nmOf(ts->Instance()).c_str():"-");
  rows.push_back(b);
  if(ts->Typedef_alias()){
    const typespec* tg = ts->Typedef_alias()->Actual_typespec();
    snprintf(b,sizeof b,"AL\t%s\t%s\t%s\t%s|%s->%s|%s", root.c_str(), path.c_str(), sp(t).c_str(),
             kn(t).c_str(), nmOf(t).c_str(), tg?nmOf(tg).c_str():"<null>",
             tg&&tg->Typedef_alias()?"aliased":"leaf");
    rows.push_back(b);
    emitTs(ts->Typedef_alias(), root, path+">a", d+1);
  }
  if(t->UhdmType()==uhdmarray_typespec) emitTs(((const array_typespec*)t)->Elem_typespec(), root, path+">e", d+1);
  if(t->UhdmType()==uhdmpacked_array_typespec) emitTs(((const packed_array_typespec*)t)->Elem_typespec(), root, path+">e", d+1);
}

template<class V> static void walkNamed(const V* v, const std::string& root, const char* field){
  if(!v) return;
  for(auto* x : *v){
    if(!x) continue;
    std::string p = std::string(field)+"["+nmOf(x)+"]";
    if(const nets*n=any_cast<const nets*>((const any*)x)){ emitTs(n->Typespec(), root, p, 0); continue; }
    if(const variables*va=any_cast<const variables*>((const any*)x)){ emitTs(va->Typespec(), root, p, 0); continue; }
    if(const parameter*pa=any_cast<const parameter*>((const any*)x)){ emitTs(pa->Typespec(), root, p, 0); continue; }
    if(const typespec*t=any_cast<const typespec*>((const any*)x)){ emitTs(t, root, p, 0); continue; }
  }
}

static void walkRoot(const BaseClass* r){
  std::string root = kn(r)+"["+full(r)+"]";
  const instance* in = any_cast<const instance*>((const any*)r);
  if(!in) return;
  if(in->Param_assigns()) for(auto* pa: *in->Param_assigns()){
    std::string nm = nmOf(pa->Lhs());
    if(const parameter*lp=any_cast<const parameter*>(pa->Lhs())) emitTs(lp->Typespec(), root, "pa["+nm+"].lhs", 0);
    if(const expr*e=any_cast<const expr*>(pa->Rhs())) emitTs(e->Typespec(), root, "pa["+nm+"].rhs", 0);
  }
  walkNamed(in->Parameters(), root, "param");
  walkNamed(in->Nets(), root, "net");
  walkNamed(in->Variables(), root, "var");
  walkNamed(in->Typespecs(), root, "tslist");
}

int main(int argc,char**argv){
  Serializer s; auto r=s.Restore(std::string(argv[1]));
  if(r.empty()){fprintf(stderr,"RESTORE_FAILED\n");return 3;}
  for(auto&pr:s.AllObjects()){
    const BaseClass*bo=pr.first; if(!bo) continue;
    auto t=bo->UhdmType();
    if(t==uhdmmodule_inst||t==uhdminterface_inst||t==uhdmpackage||t==uhdmprogram) walkRoot(bo);
    const typespec* ts = any_cast<const typespec*>((const any*)bo);
    if(ts && !ts->VpiName().empty()){
      char b[2048];
      snprintf(b,sizeof b,"GA\t%s\t%s\t%s\t%s", kn(bo).c_str(), sp(bo).c_str(), nmOf(bo).c_str(),
               ts->Typedef_alias()&&ts->Typedef_alias()->Actual_typespec()?nmOf(ts->Typedef_alias()->Actual_typespec()).c_str():"-");
      rows.push_back(b);
    }
  }
  std::sort(rows.begin(),rows.end());
  for(auto&l:rows) printf("%s\n",l.c_str());
  return 0;
}
