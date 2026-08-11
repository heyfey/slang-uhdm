// r10oth6 arm 3 -- VERIFIER-ADDED.  Two spellings law C's span arithmetic
// never saw.  `§ virtualIfaceTsIsInterfaceTs6` computes
//     SourceRange(vts6.name.range().start(),
//                 vts6.modport ? vts6.modport->sourceRange().end()
//                              : vts6.name.range().end())
// which IGNORES `VirtualInterfaceTypeSyntax::parameters` entirely (the member
// exists -- slang AllSyntax.h, `struct VirtualInterfaceTypeSyntax`).  So a
// PARAMETERISED virtual interface WITHOUT a modport should end at the interface
// NAME, dropping `#(...)`.  With a modport the modport end covers it, so p2 is
// the control that isolates the defect to the no-modport half.
// LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
interface p_if #(parameter int W = 8) (input bit clk);
  logic [W-1:0] a;
  modport IP(input clk, output a);
endinterface

// p1 -- PARAMETERISED, NO modport: the half law C's span cannot reach.
class p1_paramnomp;
  virtual p_if #(.W(4))  vi;
  int                    after;
endclass

// p2 -- CONTROL: parameterised WITH a modport, where the modport end token
//       covers the `#(...)` anyway.
class p2_parammp;
  virtual p_if #(.W(4)).IP  vi;
  int                       after;
endclass

module top4;
  bit clk;
  p_if #(.W(4)) u(clk);
  // pm1 / pm2 -- MODULE-SCOPE, which is the only position law C actually runs
  // in: a class PROPERTY never reaches makeTypespec at all, because law A
  // (`virtualIfacePropIsBareLogicVar6`) pushes the var and `continue`s before
  // the ref_typespec is built.  So the span arithmetic must be measured HERE.
  virtual p_if #(.W(4))     pm1;   // parameterised, NO modport
  virtual p_if #(.W(4)).IP  pm2;   // parameterised, WITH modport (control)
  p1_paramnomp h;
endmodule
