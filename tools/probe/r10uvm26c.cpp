// r10uvm26c — per-package-view VECTOR SIZES.  'r=1 failLhs=<package>' from
// uhdm-cmp is a vector SIZE mismatch on the container itself, so the first
// question is WHICH vector: this prints every one of a package's listings, for
// both views, so golden and ours can be diffed side by side.
//   r10uvm26c <file.uhdm> [pkgFilter]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <string>
using namespace UHDM;

template <typename V>
static size_t sz(const V* v) { return v ? v->size() : 0; }

static void go(const VectorOfpackage* v, const char* tag, const std::string& f) {
    if (!v) return;
    for (auto* p : *v) {
        std::string nm(p->VpiName());
        if (!f.empty() && nm.find(f) == std::string::npos) continue;
        std::cout << tag << "[" << nm << "]"
                  << " ts=" << sz(p->Typespecs())
                  << " cls=" << sz(p->Class_defns())
                  << " par=" << sz(p->Parameters())
                  << " pas=" << sz(p->Param_assigns())
                  << " tf=" << sz(p->Task_funcs())
                  << " var=" << sz(p->Variables())
                  << " net=" << sz(p->Nets())
                  << " arrn=" << sz(p->Array_nets())
                  << " lets=" << sz(p->Let_decls())
                  // ...and every OTHER vector package::Compare reaches through
                  // instance::Compare / scope::Compare, because a
                  // 'failLhs=<package>' pair is a vector SIZE mismatch and the
                  // first six are not always the guilty one (SeqDriver).
                  << " scp=" << sz(p->Scopes())
                  << " ii=" << sz(p->Instance_items())
                  << " lv=" << sz(p->Logic_vars())
                  << " av=" << sz(p->Array_vars())
                  << " avm=" << sz(p->Array_var_mems())
                  << " viv=" << sz(p->Virtual_interface_vars())
                  << " ne=" << sz(p->Named_events())
                  << " nea=" << sz(p->Named_event_arrays())
                  << " prop=" << sz(p->Property_decls())
                  << " seq=" << sz(p->Sequence_decls())
                  << " cassn=" << sz(p->Concurrent_assertions())
                  << " assn=" << sz(p->Assertions())
                  << " spar=" << sz(p->Spec_params())
                  << " attr=" << sz(p->Attributes())
                  << " prog=" << sz(p->Programs())
                  << " proga=" << sz(p->Program_arrays())
                  << "\n";
    }
}

int main(int argc, char** argv) {
    Serializer s;
    auto h = s.Restore(std::filesystem::path(argv[1]));
    const design* d = (const design*)((uhdm_handle*)h[0])->object;
    std::string f = argc > 2 ? argv[2] : "";
    go(d->AllPackages(), "DEFPKG", f);
    go(d->TopPackages(), "ELABPKG", f);
    return 0;
}
