// lvall <db>: every foreach loop variable under every package (both views) and class method, with its typespec actual and (for ref_var) its actual
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <iostream>
using namespace UHDM;
static std::string nm(const any*a){ if(!a) return "null"; return std::string(UhdmName(a->UhdmType()))+":"+std::string(a->VpiName())+"@"+std::to_string(a->VpiLineNo())+":"+std::to_string(a->VpiColumnNo());}
static std::string ch(const any*o){ std::string s; o=o?o->VpiParent():nullptr; for(int i=0;i<4&&o;i++,o=o->VpiParent()) s+="<"+nm(o); return s;}
static std::string ts(const any* v){ const ref_typespec* r=nullptr; if(auto*x=any_cast<const variables*>(v)) r=x->Typespec(); if(!r) return "ts=null"; auto*a=r->Actual_typespec(); std::string s="ts="+nm(a); if(a&&a->Instance()) s+="[inst "+std::string(a->Instance()->VpiName())+"]"; return s;}
static void walk(const any* s, const std::string& ctx){ if(!s) return;
  if(s->UhdmType()==uhdmforeach_stmt){ auto*f=(const foreach_stmt*)s; if(f->VpiLoopVars()) for(auto*v:*f->VpiLoopVars()){ std::cout<<ctx<<" @"<<f->VpiLineNo()<<" "<<nm(v)<<" "<<ts(v); if(auto*rv=any_cast<const ref_var*>(v)){ auto*a=rv->Actual_group(); std::cout<<" -> "<<nm(a)<<" "<<ch(a)<<" "<<(a?ts(a):"");} std::cout<<"\n";} walk(f->VpiStmt(),ctx); return; }
  if(auto*bb=any_cast<const begin*>(s)) { if(bb->Stmts()) for(auto*x:*bb->Stmts()) walk(x,ctx);} if(auto*nb=any_cast<const named_begin*>(s)) { if(nb->Stmts()) for(auto*x:*nb->Stmts()) walk(x,ctx);}
  if(auto*i=any_cast<const if_stmt*>(s)) walk(i->VpiStmt(),ctx);
  if(auto*i=any_cast<const if_else*>(s)) { walk(i->VpiStmt(),ctx); walk(i->VpiElseStmt(),ctx);} 
  if(auto*i=any_cast<const for_stmt*>(s)) walk(i->VpiStmt(),ctx);
}
static void tfs(const VectorOftask_func* l,const std::string& ctx){ if(l) for(auto*t:*l) walk(t->Stmt(),ctx+"/"+std::string(t->VpiFullName()));}
int main(int argc,char**argv){ Serializer sa; auto ha=sa.Restore(std::filesystem::path(argv[1])); auto*da=(design*)((uhdm_handle*)ha[0])->object;
 for(int k=0;k<2;k++){ auto*l=k?da->TopPackages():da->AllPackages(); if(!l) continue; for(auto*p:*l){ std::string c=(k?"TOP:":"DEF:")+std::string(p->VpiName()); tfs(p->Task_funcs(),c); if(p->Class_defns()) for(auto*cd:*p->Class_defns()) tfs(cd->Task_funcs(),c+"/cls"); } }
 if(da->AllClasses()) for(auto*cd:*da->AllClasses()) tfs(cd->Task_funcs(),"ALLCLS");
 auto mods=[&](const VectorOfmodule_inst* l,const char*t){ if(l) for(auto*m:*l) tfs(m->Task_funcs(),std::string(t)+std::string(m->VpiName()));};
 mods(da->AllModules(),"MOD:"); 
}
