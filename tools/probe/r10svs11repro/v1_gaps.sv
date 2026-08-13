// r10svs11 VERIFIER arm v1 — THE EMPTY PRODUCT CELLS of the implementer's grid.
//
// § udpShapedConnNoIfaceNet11 is now decided by `udpShapedInstantiation`, whose
// branches the implementer's c1/c2/c3 grid does NOT all exercise.  Unexercised
// branches, each one a cell where the shipped gate CHANGES its answer from the
// pristine `hasOrderedConns && mixed9` and NOTHING measured golden:
//
//   w1  a NAMED #() override               -> predicate returns false  -> MINT
//   w2  a CONCATENATION first terminal     -> isNetLvalueSyntax TRUE   -> NONE
//   w3  an ELEMENT-SELECT first terminal   -> isNetLvalueSyntax TRUE   -> NONE
//   w4  a MEMBER-ACCESS first terminal     -> isNetLvalueSyntax TRUE   -> NONE
//   w5  a #(1) single ordered override     -> still delay2             -> NONE
//   w6/w7 ONE interface, TWO children, the udp-shaped site FIRST — the
//        ifaceConnNet ANCHOR interaction the implementer's grid excluded by
//        construction ("every interface is connected to exactly one child").
//   w8/w9 the same pair with the udp-shaped site SECOND (control).
interface ifa(input bit clk);
  logic sig;
  modport MP(input clk, output sig);
endinterface

module k1  (ifa.MP m);                            logic q; endmodule
module k2  (ifa.MP m, ifa.MP n);                  logic q; endmodule
module kim (input logic a, ifa.MP m);             logic q; endmodule
module kim2(input logic [1:0] a, ifa.MP m);       logic q; endmodule
module kp #(parameter int P1 = 0, parameter int P2 = 0)
           (ifa.MP m, input logic a);             logic q; endmodule

module top();

typedef struct packed { logic f; logic g; } st_t;

bit Clock;
logic [3:0] arr;
st_t sv;

ifa w1i(Clock);
ifa w2i(Clock);
ifa w3i(Clock);
ifa w4i(Clock);
ifa w5i(Clock);
ifa w6a(Clock);  ifa w6b(Clock);
ifa w8a(Clock);  ifa w8b(Clock);

// w1  NAMED #() override, 2 ordered terminals, interface FIRST.
kp #(.P1(1)) v1 (w1i, Clock);
// w2  CONCATENATION first terminal (a net_lvalue by the LRM).
kim2 v2 ({Clock, Clock}, w2i);
// w3  ELEMENT SELECT first terminal.
kim  v3 (arr[0], w3i);
// w4  MEMBER ACCESS first terminal.
kim  v4 (sv.f, w4i);
// w5  #(1): ONE ordered override value, still inside delay2.
kp #(1) v5 (w5i, Clock);
// w6/w7  ONE interface (w6a) at TWO connection sites, UDP-SHAPED site FIRST.
k2 v6 (w6a, w6b);
k1 v7 (.m(w6a));
// w8/w9  the control: the NAMED site first, the udp-shaped site second.
k1 v8 (.m(w8a));
k2 v9 (w8a, w8b);

endmodule
