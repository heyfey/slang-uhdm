// r10earl59 VERIFIER arm W1 — the BINDER'S REACH: bindVariable (CompileStmt.cpp
// :3089) has cases for uhdmfunction / uhdmtask / uhdmbegin / uhdmmodule_inst
// and NOTHING ELSE.  There is NO uhdminterface_inst case, so from a gen scope
// inside an INTERFACE the walk recurses PAST the interface.  The patch's fence
// is `symModuleLevel` = "the LHS symbol's parent scope is an InstanceBody",
// and in slang an INTERFACE body is an InstanceBody too.
// PREDICTION: golden leaves the interface-level LHS UNBOUND at d2 even with an
// operation Rhs; the patched binary binds it => pristine-right -> patched-wrong.
interface w1ifc (input logic clk);
  logic [3:0] i_src;
  logic       i_e;
  wire  [3:0] i_net_d2;      // interface-level NET   LHS, d2, operation Rhs
  logic [3:0] i_var_d2;      // interface-level VAR   LHS, d2, operation Rhs
  wire  [3:0] i_net_d1;      // interface-level NET   LHS, d1, operation Rhs
  assign i_src = 4'h5;
  assign i_e   = 1'b0;
  if (1) begin : g_a
    wire [3:0] a_net;
    assign a_net    = i_src;
    assign i_net_d1 = i_e ? 4'b0 : a_net;
    if (1) begin : g_b
      wire [3:0] b_net;
      assign b_net    = i_src;
      assign i_net_d2 = i_e ? 4'b0 : b_net;
      assign i_var_d2 = i_e ? 4'b0 : b_net;
    end
  end
endinterface

module w1sub (input logic clk, output logic [3:0] o);
  w1ifc u_if (.clk(clk));
  assign o = u_if.i_net_d2;
endmodule

module a1;
  wire clk;
  wire [3:0] o1;
  w1sub u_sub (.clk(clk), .o(o1));
endmodule
