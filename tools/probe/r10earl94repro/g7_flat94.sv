// r10earl94 arm g6 -- the same cast-operand row at instance DEPTH 1, 2 and 3,
// and with a NESTED gen block beside it (prim_lfsr's shape).  MEASUREMENT ONLY.
module ch7_94 #(parameter int unsigned W = 8) (
  input  logic [W-1:0] a_i,
  input  logic [W-1:0] b_i,
  output logic [W-1:0] y_o,
  output logic [W-1:0] z_o
);
  logic [W-1:0] m_var;
  assign m_var = a_i;
  if (W > 2) begin : gen_top
    assign z_o = b_i;
    assign y_o = W'(a_i) ^ W'(m_var) ^ b_i;
  end
endmodule

module mid7_94 #(parameter int unsigned W = 8) (
  input logic [W-1:0] a_i, b_i, output logic [W-1:0] y_o, z_o);
  ch7_94 #(.W(W)) u_c (.a_i(a_i), .b_i(b_i), .y_o(y_o), .z_o(z_o));
endmodule

module out7_94 #(parameter int unsigned W = 8) (
  input logic [W-1:0] a_i, b_i, output logic [W-1:0] y_o, z_o);
  mid7_94 #(.W(W)) u_m (.a_i(a_i), .b_i(b_i), .y_o(y_o), .z_o(z_o));
endmodule

module g7_flat94_top (
  input logic [7:0] a8, b8,
  output logic [7:0] y1,z1,y2,z2,y3,z3
);
  ch7_94  #(.W(8)) u_d1 (.a_i(a8), .b_i(b8), .y_o(y1), .z_o(z1));
  mid7_94 #(.W(8)) u_d2 (.a_i(a8), .b_i(b8), .y_o(y2), .z_o(z2));
  out7_94 #(.W(8)) u_d3 (.a_i(a8), .b_i(b8), .y_o(y3), .z_o(z3));
endmodule
