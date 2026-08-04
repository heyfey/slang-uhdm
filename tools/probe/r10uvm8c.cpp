// r10uvm8c: census of io_decl SHAPE — for every io_decl, the vector/pointer
// fields a Compare can fail on (Ranges, Attributes, Expr, Typespec actual),
// keyed by owning subroutine.  Answers "which field of the io_decl does the
// body differ see as present-in-golden / absent-in-ours".
//   r10uvm8c <file.uhdm>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <string>
using namespace UHDM;

static std::string ownerOf(const BaseClass* o) {
    int guard = 0;
    std::string sub;
    while (o && guard++ < 40) {
        switch (o->UhdmType()) {
            case uhdmfunction:
            case uhdmtask:
                if (sub.empty()) sub = std::string(o->VpiName());
                break;
            case uhdmclass_defn:
                return "class:" + std::string(o->VpiName()) + "/" + sub;
            case uhdmpackage:
                return "pkg:" + std::string(o->VpiName()) + "/" + sub;
            case uhdmmodule_inst:
                return "mod:" + std::string(o->VpiName()) + "/" + sub;
            default:
                break;
        }
        o = o->VpiParent();
    }
    return "?/" + sub;
}

int main(int argc, char** argv) {
    Serializer s;
    auto h = s.Restore(std::filesystem::path(argv[1]));
    (void)h;
    for (auto& kv : s.AllObjects()) {
        auto* o = (const BaseClass*)kv.first;
        if (!o || o->UhdmType() != uhdmio_decl) continue;
        auto* io = (const io_decl*)o;
        auto* rgs = io->Ranges();
        const any* ex = io->Expr();
        auto* rt = io->Typespec();
        const any* ts = rt ? rt->Actual_typespec() : nullptr;
        std::cout << io->VpiName() << "|rng="
                  << (rgs ? std::to_string(rgs->size()) : std::string("-"))
                  << "|vec=" << (io->VpiVector() ? 1 : 0) << "|expr=" << (ex ? UhdmName(ex->UhdmType()) : "-")
                  << "|rts=" << (rt ? "y" : "-")
                  << "|ts=" << (ts ? UhdmName(ts->UhdmType()) : "-")
                  << "|dir=" << io->VpiDirection() << "|" << ownerOf(io->VpiParent())
                  << "|" << io->VpiLineNo() << ":" << io->VpiColumnNo();
        if (rgs)
            for (auto* r : *rgs) {
                auto d1 = [](const any* e) -> std::string {
                    if (!e) return "-";
                    std::string s = UhdmName(e->UhdmType());
                    if (e->UhdmType() == uhdmconstant) {
                        auto* c = (const constant*)e;
                        s += "(" + std::string(c->VpiDecompile()) + ",ct" +
                             std::to_string(c->VpiConstType()) + ",sz" +
                             std::to_string(c->VpiSize()) + ",v=" +
                             std::string(c->VpiValue()) + ",@" +
                             std::to_string(c->VpiLineNo()) + ":" +
                             std::to_string(c->VpiColumnNo()) + "-" +
                             std::to_string(c->VpiEndLineNo()) + ":" +
                             std::to_string(c->VpiEndColumnNo()) + ")";
                    } else if (e->UhdmType() == uhdmoperation) {
                        auto* op = (const operation*)e;
                        s += "[op" + std::to_string(op->VpiOpType());
                        if (auto* ops = op->Operands())
                            for (auto* x : *ops)
                                s += " " + std::string(UhdmName(x->UhdmType())) +
                                     "'" + std::string(x->VpiName()) + "'";
                        s += "]";
                    } else if (!e->VpiName().empty()) {
                        s += "(" + std::string(e->VpiName()) + ")";
                    }
                    return s;
                };
                std::cout << "|RNG " << d1(r->Left_expr()) << " .. "
                          << d1(r->Right_expr()) << " @" << r->VpiLineNo()
                          << ":" << r->VpiColumnNo() << "-"
                          << r->VpiEndLineNo() << ":" << r->VpiEndColumnNo();
            }
        std::cout << "\n";
    }
    return 0;
}
