// addvif <in.uhdm> <out.uhdm>: SIMULATION ONLY (the sister's ParamEmit face): copy the TOP-view tb_params_pkg's
// interface_typespec typedefs into the DEFINITION view's vpiTypedef, in golden's order (master, monitor) at the front,
// parented and instanced at the definition view, spanned from the interface name (golden 54:17 / 53:17)
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <uhdm/ElaboratorListener.h>
#include <uhdm/clone_tree.h>
#include <filesystem>
#include <iostream>
#include <algorithm>
using namespace UHDM;
int main(int argc,char**argv){ Serializer s; auto h=s.Restore(std::filesystem::path(argv[1])); auto*d=(design*)((uhdm_handle*)h[0])->object;
 package *def=nullptr,*top=nullptr; for(auto*p:*d->AllPackages()) if(p->VpiName()=="tb_params_pkg") def=p; for(auto*p:*d->TopPackages()) if(p->VpiName()=="tb_params_pkg") top=p;
 std::vector<typespec*> add; for(auto*t:*top->Typespecs()) if(t->UhdmType()==uhdminterface_typespec) add.push_back(t);
 std::sort(add.begin(),add.end(),[](auto*a,auto*b){return a->VpiName()<b->VpiName();}); // master < monitor
 ElaboratorContext ctx(&s,false,true); auto* nv=s.MakeTypespecVec(); int k=0;
 for(auto*t:add){ auto*c=(typespec*)clone_tree(t,&ctx); c->VpiParent(def); c->Instance(def); c->VpiColumnNo(17); nv->push_back(c); k++; }
 for(auto*t:*def->Typespecs()) nv->push_back(t); def->Typespecs(nv);
 std::cout<<"added "<<k<<"\n"; s.Save(std::filesystem::path(argv[2])); }
