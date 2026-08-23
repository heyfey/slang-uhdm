// r10earl72 — whole-database OBJECT-KIND HISTOGRAM, read directly from the
// .uhdm (Earlgrey's uhdm-dump is >1 GB and hours; RESUME §8 forbids a whole-dump
// diff here).  Used to prove that a patch adds ONLY the objects its law mints.
// MEASUREMENT ONLY.  usage: kh72 <db.uhdm>
#include <uhdm/uhdm.h>
#include <uhdm/UhdmListener.h>
#include <cstdio>
#include <map>
#include <string>
using namespace UHDM;
static std::map<std::string,long> H;
struct K : public UhdmListener { void enterAny(const any* const o) final { H[std::string(UhdmName(o->UhdmType()))]++; } };
int main(int argc,char**argv){ if(argc<2) return 2; Serializer s;
  auto r=s.Restore(std::string(argv[1])); K k;
  for(auto h:r){const any*o=(const any*)((const uhdm_handle*)h)->object; if(auto*d=any_cast<const design*>(o)) k.listenDesign(d);}
  for(auto&p:H) printf("%s %ld\n",p.first.c_str(),p.second); return 0; }
