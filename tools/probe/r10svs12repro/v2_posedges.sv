// r10svs12 VERIFIER arm v2 — the POSITIONAL branch's own edges.
//
// The patch changes behaviour ONLY when `hasOrderedConns` is true, so the cells
// that can hide a regression are the odd POSITIONAL ones.  d1-d4 test the
// positional branch with a bare net, an element select, an operation, a literal
// and an escaped net.  Five positional shapes are still unmeasured and each one
// reaches a different line of the changed block:
//
//   x1/x2  an EMPTY positional terminal (`(Clock, )`) — `connectionExpr` is
//          null for it, so the loop `continue`s BEFORE the changed lines; the
//          cell measures whether golden mints a port there (the positional twin
//          of d1 h6, which is residue R2).
//   x3     a MULTI-DIMENSIONAL instance array, positional.
//   x4     a HIERARCHICAL actual (`sub.q`) — `rsym->name` is the LEAF name, so
//          the new `connScopeA + "." + rsym->name` fullname is the cell that
//          shows whether golden scopes a hierarchical actual the same way.
//   x5     a CONCATENATION actual, positional, on a MODULE array — the
//          `getSymbolReference()` path (an interface array skips it, d3 k5).
//
// LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
interface if1(input bit clk);
  logic sig;
endinterface

interface if2(input bit clk, input bit rst);
  logic sig;
endinterface

module leaf1(input bit a);
  logic q;
endmodule

module leaf2(input bit a, input bit b);
  logic q;
endmodule

module top();

bit Clock;
bit Rst;
bit [3:0] Vec;

// x1  MODULE array, POSITIONAL, second terminal EMPTY
leaf2 x1[4](Clock, );
// x2  INTERFACE array, POSITIONAL, second terminal EMPTY
if2 x2[4](Clock, );
// x3  MULTI-DIMENSIONAL interface array, POSITIONAL
if1 x3[2][2](Clock);
// x4  MODULE array, POSITIONAL, HIERARCHICAL actual
leaf1 x4inst(Clock);
leaf1 x4[4](x4inst.q);
// x5  MODULE array, POSITIONAL, CONCATENATION actual
leaf1 x5[4]({Vec[0]});

endmodule
