// r10det1repro/dttf.cpp — print the ORDER of every TASK_FUNC listing vector as
// source identities, one line per vector, sorted whole-line so no owner identity
// enters the comparison (see dtvec.cpp's header for why that matters).
//
// THIS IS THE PROBE THAT NAMED THE BUG.  Two reps of ONE binary on Scoreboard
// differ in bytes while `uhdm-cmp` calls them EQUAL and the dumps are
// multiset-identical; a dump diff can only say "94 lines moved".  This says
// WHICH vector: `design->Task_funcs()`, 917 entries, head `uvm_hdl_check_path`
// on one rep and `get_name` (svunit_pkg) on the other.  Golden's head is
// `uvm_hdl_check_path`.
//   usage: dttf <db.uhdm>   -> "<count>\t<ownerkind>\t<ownername>\t<seq>"
// GUARD: zero task_func vectors is UNMEASURED, exit 4 — never read as "empty".
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <iostream>
#include <string>
using namespace UHDM;
static size_t nvec=0;
static void emit(const char* okind, const BaseClass* o, const VectorOftask_func* v){
    if(!v) return; ++nvec;
    std::string seq;
    for(auto* t:*v){ char b[256]; snprintf(b,sizeof(b),"%s@%u:%u ", t?std::string(t->VpiName()).c_str():"-", t?t->VpiLineNo():0u, t?t->VpiColumnNo():0u); seq+=b; }
    printf("%zu\t%s\t%s\t%s\n", v->size(), okind, std::string(o->VpiName()).c_str(), seq.c_str());
}
int main(int argc,char**argv){
    Serializer s; if(s.Restore(std::string(argv[1])).empty()){std::cerr<<"UNMEASURED\n";return 4;}
    for(auto& kv:s.AllObjects()){ const BaseClass*o=kv.first; if(!o) continue;
        switch(o->UhdmType()){
            case uhdmdesign: emit("design",o,((const design*)o)->Task_funcs()); break;
            case uhdmpackage: emit("package",o,((const package*)o)->Task_funcs()); break;
            case uhdmclass_defn: emit("class_defn",o,((const class_defn*)o)->Task_funcs()); break;
            case uhdmmodule_inst: emit("module_inst",o,((const module_inst*)o)->Task_funcs()); break;
            default: break; } }
    if(!nvec){std::cerr<<"UNMEASURED: no task_func vectors\n";return 4;}
    fprintf(stderr,"VECTORS n=%zu\n",nvec); return 0; }
