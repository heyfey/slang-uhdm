// r10earl32 arm 3 — THE CONTAINER AXIS, and the NO-FOLD CONTAINERS.
//
// Origin and position held at the witness's (`logic [11:0] P = 12'h380`, read
// as a module-local function-call argument).  Only the CONTAINER changes.
//
// This arm exists because the fix is a FALL-THROUGH: the call-argument arm no
// longer returns early, so every no-fold container law this file already
// carries (§ defGenProcWildcardPkgParamNoFold19,
// § genNestedScopePkgParamNoFold24, the package-init arms, the param-init
// arms) now applies to a call argument for the first time.  Each of them must
// still win, and each cell here is one of them.
package c32;
  localparam logic [11:0] P = 12'h380;
  localparam logic [11:0] Q = 12'h123;
  function automatic logic [31:0] pfn(logic [11:0] v); return {v, 20'h0}; endfunction
endpackage

module c32sub #(parameter int W = 1) (input logic [11:0] i_i, output logic [31:0] o);
  assign o = {i_i, 20'h0} ^ 32'(W);
endmodule

module c32a #(
  // g1  a module PARAMETER DEFAULT that is a call taking a pkg param
  parameter int PD = c32::pfn(c32::P)
) (
  input  logic        c_i,
  output logic [31:0] o1, o2, o3, o4, o5, o6, o7
);
  import c32::*;
  function automatic logic [31:0] mf(logic [11:0] v); return {v, 20'h0}; endfunction

  // g2  a module LOCALPARAM initialised by a call taking a pkg param
  localparam int L = mf(c32::P);

  assign o1 = 32'(PD);
  assign o2 = 32'(L);

  // g3 / g4  a DEF-view GENERATE-BLOCK PROCESS: the BARE read is NOT
  // substituted (§ defGenProcWildcardPkgParamNoFold19) while the QUALIFIED one
  // in the same process still folds.  If the fall-through breaks that split,
  // this is where it shows.
  logic [31:0] g3r, g4r;
  generate
    if (1) begin : gblk
      always_comb begin
        g3r = mf(P);                       // g3  BARE, def-view gen process
        g4r = mf(c32::P);                  // g4  QUALIFIED, same process
      end
    end
  endgenerate
  assign o3 = g3r; assign o4 = g4r;

  // g5  a NESTED generate scope (§ genNestedScopePkgParamNoFold24)
  logic [31:0] g5r;
  generate
    for (genvar gi = 0; gi < 2; gi++) begin : gouter
      if (gi == 0) begin : ginner
        always_comb g5r = mf(P);           // g5  BARE, nested gen scope
      end
    end
  endgenerate
  assign o5 = g5r;

  // g6  a PORT-CONNECTION actual that is a call taking a pkg param
  c32sub #(.W(2)) u_sub (.i_i(c32::P[11:0]), .o(o6));

  // g7  the ternary/condition container, both arms folded
  assign o7 = c_i ? mf(c32::P) : mf(c32::Q);
endmodule

// g8 / g9 — the PACKAGE-INIT containers: a package localparam initialised by a
// call taking its OWN package's parameter, and one taking ANOTHER package's.
package c32b;
  import c32::*;
  function automatic logic [31:0] bfn(logic [11:0] v); return {v, 20'h0}; endfunction
  localparam logic [11:0] R = 12'h222;
  localparam int G8 = bfn(R);              // g8  same-package param
  localparam int G9 = bfn(c32::P);         // g9  other-package param, qualified
endpackage

// g10 — the same call in a module instantiated TWICE (def listing + 2 elab)
module c32c (input logic [2:0] s_i, output logic [31:0] o);
  function automatic logic [31:0] mf(logic [11:0] v); return {v, 20'h0}; endfunction
  assign o = mf(c32::P) ^ 32'(s_i);        // g10
endmodule

module c32top;
  logic c;
  logic [2:0] s;
  logic [31:0] a1,a2,a3,a4,a5,a6,a7,d1,d2;
  c32a ua (.c_i(c), .o1(a1), .o2(a2), .o3(a3), .o4(a4), .o5(a5), .o6(a6), .o7(a7));
  c32c uc1 (.s_i(s), .o(d1));
  c32c uc2 (.s_i(s), .o(d2));
  localparam int G11 = c32b::G8 + c32b::G9;
endmodule
