#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <iostream>
using namespace UHDM;
template<class V> static std::string sz(V*v){ return v? std::to_string(v->size()):"null"; }
int main(int argc,char**argv){
  Serializer sa; auto ha=sa.Restore(std::filesystem::path(argv[1]));
  auto*d=(design*)((uhdm_handle*)ha[0])->object;
  std::cout<<"inc "<<sz(d->Include_file_infos())<<" allpk "<<sz(d->AllPackages())<<" toppk "<<sz(d->TopPackages())<<" allcls "<<sz(d->AllClasses())<<" allif "<<sz(d->AllInterfaces())<<" udps "<<sz(d->AllUdps())<<" progs "<<sz(d->AllPrograms())<<" allmod "<<sz(d->AllModules())<<" ts "<<sz(d->Typespecs())<<" lets "<<sz(d->Let_decls())<<" tf "<<sz(d->Task_funcs())<<" par "<<sz(d->Parameters())<<" pa "<<sz(d->Param_assigns())<<" topmod "<<sz(d->TopModules())<<"\n";
}
