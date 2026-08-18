// v65 ARM 8 — a module with NO top instantiation at all, so the ONLY port
// High_conn rows in the database are DEF-view (§ elabConnEmit21 must be FALSE
// there).  Every cell must be byte-identical.  MEASUREMENT ONLY.
package pa8;
  localparam int PW = 5;
  localparam int PB = 2;
endpackage
module leaf8 (input logic [31:0] a_i, input logic b_i, output logic o_o);
  assign o_o = ^a_i ^ b_i;
endmodule
module orphan8 import pa8::*; (input logic [63:0] d_i, output logic [2:0] o_o);
  leaf8 u_w (.a_i(d_i[0  +: PW]), .b_i(d_i[0]), .o_o(o_o[0]));
  leaf8 u_b (.a_i(d_i[PB +: 32]), .b_i(d_i[0]), .o_o(o_o[1]));
  leaf8 u_p (.a_i({27'b0, d_i[PW-1:PB]}), .b_i(d_i[0]), .o_o(o_o[2]));
endmodule
