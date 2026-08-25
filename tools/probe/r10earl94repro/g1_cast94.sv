// r10earl94 arm g1 -- a reference inside a SIZE CAST in an ELABORATED gen-scope
// cont_assign, against the same name read from every other position of the same RHS.
// MEASUREMENT ONLY.
module ch1_94 #(parameter int unsigned W = 8) (
  input  logic [W-1:0] a_i,
  input  logic [W-1:0] b_i,
  output logic [W-1:0] y1_o,
  output logic [W-1:0] y2_o,
  output logic [W-1:0] y3_o,
  output logic [W-1:0] y4_o,
  output logic [W-1:0] y5_o,
  output logic [W-1:0] y6_o
);
  localparam int unsigned KOFF = 2;
  logic [W-1:0] m_net;
  logic [W-1:0] m_var;
  assign m_net = a_i;

  if (W > 2) begin : gen_if
    logic [W-1:0] g_loc;
    // r1: PORT NET inside a size cast, with a plain operand beside it
    assign y1_o = W'(a_i) ^ b_i;
    // r2: whole-RHS size cast of a PORT NET
    assign y2_o = W'(b_i);
    // r3: size cast of a MODULE-level net
    assign y3_o = W'(m_net) | a_i;
    // r4: size cast of a GEN-LOCAL
    assign g_loc = a_i;
    assign y4_o = W'(g_loc) & b_i;
    // r5: size cast of a PARAMETER
    assign y5_o = W'(W) + b_i;
    // r6: a PARAMETER read in a SELECT INDEX (head-2 shape)
    assign y6_o = m_net[W-KOFF] ? a_i : b_i;
  end
endmodule

module g1_cast94_top (
  input  logic [7:0]  a8, b8,
  input  logic [15:0] a16, b16,
  output logic [7:0]  q1,q2,q3,q4,q5,q6,
  output logic [15:0] r1,r2,r3,r4,r5,r6
);
  ch1_94 #(.W(8))  u_a (.a_i(a8),  .b_i(b8),  .y1_o(q1), .y2_o(q2), .y3_o(q3), .y4_o(q4), .y5_o(q5), .y6_o(q6));
  ch1_94 #(.W(16)) u_b (.a_i(a16), .b_i(b16), .y1_o(r1), .y2_o(r2), .y3_o(r3), .y4_o(r4), .y5_o(r5), .y6_o(r6));
endmodule
