// r10uvm7c: whole-pool census of CALL objects and whether they carry their
// resolved callee pointer (vpiFunction / vpiTask).  The body-level differ's
// head is 714 `L <null> vs R function` rows — a method call whose callee we
// resolve and golden leaves null — and no listing walk finds calls buried in
// statement trees, so census the Serializer pool directly.
//   r10uvm7c <file.uhdm> [rows]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <map>
#include <string>
using namespace UHDM;

int main(int argc, char** argv) {
    Serializer s;
    auto h = s.Restore(std::filesystem::path(argv[1]));
    (void)h;
    bool rows = argc > 2 && std::string(argv[2]) == "rows";
    std::map<std::string, std::pair<int, int>> cen;  // kind -> (set, null)
    for (auto& kv : s.AllObjects()) {
        auto* o = (const BaseClass*)kv.first;
        if (!o) continue;
        const BaseClass* callee = nullptr;
        const char* kind = nullptr;
        switch (o->UhdmType()) {
            case uhdmmethod_func_call:
                kind = "method_func_call";
                callee = ((const method_func_call*)o)->Function();
                break;
            case uhdmmethod_task_call:
                kind = "method_task_call";
                callee = ((const method_task_call*)o)->Task();
                break;
            case uhdmfunc_call:
                kind = "func_call";
                callee = ((const func_call*)o)->Function();
                break;
            case uhdmtask_call:
                kind = "task_call";
                callee = ((const task_call*)o)->Task();
                break;
            default:
                break;
        }
        if (!kind) continue;
        auto& e = cen[kind];
        if (callee) e.first++; else e.second++;
        if (rows)
            std::cout << kind << "|" << (callee ? "SET" : "null") << "|"
                      << o->VpiName() << "|" << o->VpiFile() << ":"
                      << o->VpiLineNo() << "\n";
    }
    if (!rows)
        for (auto& kv : cen)
            std::cout << kv.first << " callee_set=" << kv.second.first
                      << " callee_null=" << kv.second.second << "\n";
    return 0;
}
