// r10svs13 arm a4 — THE THIRD PARENT KIND, AND THE RE-PASS.
//
// `instGetInterfaceArrays`/`instSetInterfaceArrays` (src/EmitHelpers.h:1758)
// dispatch over THREE instance kinds: interface_inst, program, module_inst.
// a1 measures program and module_inst; this arm adds the interface_inst parent
// and a MODULE that re-passes the whole array on to a child, so the law's
// `program` clause is fenced on both sides — the kind it must fire for and the
// two kinds it must not.
//
// NOTE, and it is a measurement not an aside: a `program` CANNOT contain a
// module/interface/program instantiation (LRM 24.3), so the ONLY interface_array
// a program instance can ever carry is a PORT VIEW.  There is no
// locally-declared-interface-array cell to write for a program, which is why
// the gate cannot over-fire onto one.
interface oif(input bit clock);
  logic [7:0] d;
  modport OP(input clock, output d);
endinterface

interface holder(oif.OP a[4]);
endinterface

module leafm(oif.OP a[4]);
endmodule

module mid(oif.OP a[4]);
  leafm inner(a);
endmodule

module top();
bit Clock;
oif arr[4](Clock);

holder h1(arr);
mid d1(arr);
endmodule
