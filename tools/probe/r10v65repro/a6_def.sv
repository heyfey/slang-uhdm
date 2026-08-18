// v65 ARM 6 — the DEF-view High_conn (ref_module port connection) and a module
// that is NEVER instantiated, so the ONLY High_conn rows are DEF ones.  The
// § elabConnEmit21 marker must be FALSE here and every cell must stay
// byte-identical.  MEASUREMENT ONLY.
package pa6;
  localparam int PW = 5;
  localparam int PB = 2;
endpackage

module l6 (input logic [31:0] a_i, input logic b_i, output logic o_o);
  assign o_o = ^a_i ^ b_i;
endmodule

// never instantiated from a top module
module orphan6 import pa6::*; (input logic [63:0] d_i, output logic [1:0] o_o);
  l6 u_w (.a_i(d_i[0  +: PW]), .b_i(d_i[0]), .o_o(o_o[0]));
  l6 u_b (.a_i(d_i[PB +: 32]), .b_i(d_i[0]), .o_o(o_o[1]));
endmodule

module a6_def import pa6::*; (input logic [63:0] d_i, output logic [1:0] o_o);
  orphan6 u_o (.d_i(d_i), .o_o(o_o));
endmodule
