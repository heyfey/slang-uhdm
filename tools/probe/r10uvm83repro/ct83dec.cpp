// r10uvm83 — MEASUREMENT-ONLY.  Prints UHDM::decompile() of the object with a
// given UhdmId, so two objects from two databases can be text-diffed to name the
// FIELD PATH of a first divergence that uhdm-cmp reports only as a container.
//   usage: ct83dec <db.uhdm> <uhdmId> [<uhdmId> ...]
// build: g++ -O2 -std=c++17 ct83dec.cpp -I ~/.local/include \
//        -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct83dec
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <uhdm/vpi_visitor.h>
#include <cstdio>
#include <cstdlib>
#include <string>
using namespace UHDM;
int main(int argc,char** argv){
  if(argc<3){printf("usage: ct83dec <db> <id>...\n");return 2;}
  Serializer s; s.Restore(std::string(argv[1]));
  auto all=s.AllObjects();
  for(int i=2;i<argc;i++){
    unsigned want=(unsigned)strtoul(argv[i],nullptr,10);
    const BaseClass* hit=nullptr;
    for(auto& kv:all){ const BaseClass* o=(const BaseClass*)kv.first; if(o&&o->UhdmId()==want){hit=o;break;} }
    if(!hit){ printf("== ID %u NOT FOUND\n",want); continue; }
    printf("== ID %u kind=%s name=%s\n",want,std::string(UhdmName(hit->UhdmType())).c_str(),
           std::string(hit->VpiName()).c_str());
    fflush(stdout);
    std::string t=decompile((const any*)hit);
    (void)t;
  }
  return 0;
}
