// r10svs12 VERIFIER arm v1 — the axes the implementer's d1-d4 do NOT reach.
//
// d1-d4 cross connection style against port count, written order, child kind,
// container kind, actual FORM (net / select / operation / literal) and escaped
// spelling.  Three axes are still unmeasured and all three touch
// § arrayBcastPortPositionalNoFormal12's gate (`hasOrderedConns`) directly:
//
//   w1/w2  IMPLICIT `.*` — a WildcardPortConnection is neither Ordered nor
//          Named, so `hasOrderedConns` returns FALSE and the law takes the
//          NAMED branch.  Nothing in the write-up measures what golden does
//          there, and `.*` is the one connection style whose port names are
//          not written in the source at all.
//   w3/w4  THE ACTUAL IS AN INTERFACE (scalar) or an INTERFACE ARRAY passed
//          THROUGH A MODULE PORT.  This is the brief's named in-law family
//          ("interface arrays through ports", the InterfaceModPort
//          neighbourhood) and it is the only actual form in the campaign whose
//          symbol is not a net/variable.  d1-d4 never connect an interface to
//          anything.
//   w5     A POSITIONAL conn on a DESCENDING-range array, to check the port
//          span/name rule does not read the range.
//
// LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
interface if1(input bit clk);
  logic sig;
  modport MP(input clk, output sig);
endinterface

module leaf1(input bit a);
  logic q;
endmodule

module subif(if1 i);
  logic q;
endmodule

module subifarr(if1 i[4]);
  logic q;
endmodule

module top();

bit Clock;
bit clk;   // for the `.*` cells: `.*` binds by NAME, so the actual must exist
bit a;

// w1  INTERFACE array, IMPLICIT `.*` connection list
if1 w1[4](.*);
// w2  MODULE array, IMPLICIT `.*` connection list
leaf1 w2[4](.*);
// w3  MODULE array whose POSITIONAL actual is a SCALAR INTERFACE instance
if1 wif(Clock);
subif w3[4](wif);
// w4  MODULE array whose POSITIONAL actual is an INTERFACE ARRAY
if1 warr[4](Clock);
subifarr w4[2](warr);
// w5  INTERFACE array with a DESCENDING range, POSITIONAL
if1 w5[3:0](Clock);

endmodule
