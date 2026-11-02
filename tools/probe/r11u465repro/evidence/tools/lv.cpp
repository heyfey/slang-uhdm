// lv <db> <pkg> <func>: print each foreach loop var of that package function (top view), its typespec, its actual and the actual's typespec+parent chain
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <iostream>
using namespace UHDM;
static std::string ch(const BaseClass*o,int n=8){ if(!o) return "null"; std::string s; for(int i=0;i<n&&o;i++,o=o->VpiParent()) s+=std::string(i?" < ":"")+std::string(UhdmName(o->UhdmType()))+":"+std::string(o->VpiName())+"@"+std::to_string(o->VpiLineNo())+":"+std::to_string(o->VpiColumnNo()); return s;}
static std::string ts(const any* v){ const ref_typespec* r=nullptr; if(auto*x=any_cast<const variables*>(v)) r=x->Typespec(); if(!r) return "ts=null"; auto*a=r->Actual_typespec(); return std::string("ts=")+(a?std::string(UhdmName(a->UhdmType()))+":"+std::string(a->VpiName())+"@"+std::to_string(a->VpiLineNo())+":"+std::to_string(a->VpiColumnNo()):"null");}
static void walk(const any* s, int d){ if(!s) return;
  if(s->UhdmType()==uhdmforeach_stmt){ auto*f=(const foreach_stmt*)s; std::cout<<"foreach @"<<f->VpiLineNo()<<"\n"; if(f->VpiLoopVars()) for(auto*v:*f->VpiLoopVars()){ std::cout<<"  lv "<<(const void*)v<<" "<<UhdmName(v->UhdmType())<<":"<<v->VpiName()<<" "<<ts(v)<<"\n"; if(auto*rv=any_cast<const ref_var*>(v)){ auto*a=rv->Actual_group(); std::cout<<"    actual "<<(const void*)a<<" "<<ch(a)<<" "<<(a?ts(a):"")<<"\n"; if(a&&a->UhdmType()==uhdmref_var){auto*aa=((const ref_var*)a)->Actual_group(); std::cout<<"      actual2 "<<(const void*)aa<<" "<<ch(aa)<<"\n";} std::cout<<"    fe "<<(const void*)v->VpiParent()<<"\n";}} walk(f->VpiStmt(),d+1); return; }
  if(auto*b=any_cast<const scope*>(s)) { if(auto*bb=any_cast<const begin*>(s)) { if(bb->Stmts()) for(auto*x:*bb->Stmts()) walk(x,d+1);} if(auto*nb=any_cast<const named_begin*>(s)) { if(nb->Stmts()) for(auto*x:*nb->Stmts()) walk(x,d+1);} }
  if(auto*i=any_cast<const if_stmt*>(s)) walk(i->VpiStmt(),d+1);
  if(auto*i=any_cast<const if_else*>(s)) { walk(i->VpiStmt(),d+1); walk(i->VpiElseStmt(),d+1);} 
  if(auto*i=any_cast<const for_stmt*>(s)) walk(i->VpiStmt(),d+1);
}
int main(int argc,char**argv){ Serializer sa; auto ha=sa.Restore(std::filesystem::path(argv[1])); auto*da=(design*)((uhdm_handle*)ha[0])->object; std::string pn=argv[2], fn=argv[3];
 if(da->AllClasses()) for(auto*c:*da->AllClasses()) if(c->Task_funcs()) for(auto*t:*c->Task_funcs()) if(std::string(c->VpiName())+"::"+std::string(t->VpiName())==fn){ std::cout<<" allclassesfunc "<<ch(t,4)<<"\n"; walk(t->Stmt(),0);}

 for(int k=0;k<2;k++){ auto*l=k?da->TopPackages():da->AllPackages(); if(!l) continue; for(auto*p:*l) if(p->VpiName()==pn){ std::cout<<"ncls "<<(p->Class_defns()?p->Class_defns()->size():0)<<"\n"; std::cout<<(k?"TOP":"DEF")<<" pkg "<<pn<<"\n"; if(p->Task_funcs()) for(auto*t:*p->Task_funcs()) if(t->VpiName()==fn){ std::cout<<" func "<<ch(t,3)<<"\n"; walk(t->Stmt(),0);} 
   if(p->Class_defns()) for(auto*c:*p->Class_defns()) if(c->Task_funcs()) for(auto*t:*c->Task_funcs()) if(std::string(c->VpiName())+"::"+std::string(t->VpiName())==fn){ std::cout<<" classfunc "<<ch(t,3)<<"\n"; walk(t->Stmt(),0);} } }
}
