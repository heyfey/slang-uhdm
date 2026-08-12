// r10svs9 arm b1 — the SUCCESSOR head, sized: a CLASS-TYPED variable declared
// at MODULE / PROGRAM / INTERFACE scope.  Golden emits it as a `logic_net` with
// `vpiTypespec -> ref_typespec -> class_typespec (<ClassName>)` located at the
// TYPE NAME's span; SVSwitch/testcase.sv:20-21 (`Environment env;`,
// `small_packet spkt;`) are the two live sites.  This arm asks whether the
// missing link is specific to PROGRAM scope or general to class-typed nets.
class K;
  int x;
endclass

class L #(parameter int W = 1);
  int y;
endclass

typedef K K_t;

module m;
  K    mk;          // k1 module scope, class type
  K_t  mkt;         // k2 module scope, typedef'd class type
  L#(2) ml;         // k3 module scope, parameterized class
  int  plain;       // k4 control: a non-class net
endmodule

program p;
  K    pk;          // k5 PROGRAM scope (the live shape)
endprogram

interface ifc;
  K    ik;          // k6 interface scope
endinterface

module top;
  m u_m();
  ifc u_i();
endmodule
