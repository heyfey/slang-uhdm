// VERIFIER's own cell -- the spelling NO arm cell in r10oth6 covers.
// Surelog's rule is `sl_collect(classId, paVIRTUAL)` over the WHOLE class
// subtree; the patch's predicate `hasVirtualIfaceSyntax6` only matches a
// VirtualInterfaceType node.  A NESTED `virtual class` writes paVIRTUAL inside
// the outer class's subtree but contains NO VirtualInterfaceType, so the two
// predicates should DISAGREE here if the code comment's claim that they are
// "the same predicate" is wrong.
// LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
interface w_if(input bit clk);
  logic a;
  modport IP(input clk, output a);
endinterface

// x1 -- OUTER is NOT abstract and has NO virtual interface; its only `virtual`
//       is the NESTED virtual class.
class x1_outer;
  int x;
  virtual class x1_inner;
    int y;
  endclass
endclass

// x2 -- CONTROL: same shape but the nested class is NOT virtual.
class x2_outer;
  int x;
  class x2_inner;
    int y;
  endclass
endclass

module top3;
  bit clk;
  w_if u(clk);
  x1_outer h;
endmodule
