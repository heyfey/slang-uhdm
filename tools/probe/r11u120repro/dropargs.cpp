// r11u120 dropargs (EXPERIMENT ONLY, never a law): Restore a database, Erase
// every ref_obj whose parent is a func_call that does NOT list it among its
// Tf_call_args (an orphan argument left behind when the call's arguments were
// replaced), and Save.  Measures whether func_upto's order residue follows
// those 1024 orphan objects.   dropargs <in.uhdm> <out.uhdm>
#include <uhdm/uhdm.h>
#include <filesystem>
#include <iostream>
#include <vector>
using namespace UHDM;
int main(int argc, char** argv) {
    Serializer s;
    s.Restore(std::filesystem::path(argv[1]));
    std::vector<const BaseClass*> kill;
    for (auto& [o, id] : s.AllObjects()) {
        if (!o || o->UhdmType() != uhdmref_obj) continue;
        auto* p = o->VpiParent();
        if (!p || p->UhdmType() != uhdmfunc_call) continue;
        bool listed = false;
        if (auto* a = ((const func_call*)p)->Tf_call_args())
            for (auto* x : *a) if (x == o) listed = true;
        if (!listed) kill.push_back(o);
    }
    for (auto* k : kill) s.Erase(k);
    std::cerr << "erased " << kill.size() << "\n";
    s.Save(std::filesystem::path(argv[2]));
}
