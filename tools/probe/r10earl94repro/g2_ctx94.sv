// r10earl94 arm g2 -- the CONTEXT grid for a cast-operand reference in an
// ELABORATED gen scope: cast at RHS top, cast under an operation, cast under a
// select, cast in a PROCESS, cast at MODULE level, cast in a High_conn, cast in
// a dimension bound.  MEASUREMENT ONLY.
module leaf2_94 #(parameter int unsigned W = 8) (input logic [W-1:0] p_i, output logic [W-1:0] p_o);
  assign p_o = p_i;
endmodule

module ch2_94 #(parameter int unsigned W = 8) (
  input  logic [W-1:0] a_i,
  input  logic [W-1:0] b_i,
  output logic [W-1:0] c1_o, c2_o, c3_o, c4_o, c5_o, c6_o
);
  logic [W-1:0] m_var;
  logic [W-1:0] c4_int;
  wire  [W-1:0] m_wire = a_i;

  // MODULE-level cast (outside any gen scope)
  assign c1_o = W'(a_i) ^ b_i;

  if (W > 2) begin : gen_if
    // n1: cast under an operation
    assign c2_o = W'(a_i) ^ b_i;
    // n2: cast under a SELECT of the cast result
    assign c3_o = {W{1'b0}} | W'(m_wire);
    // n3: cast operand in a PROCESS
    always_comb c4_int = W'(a_i) ^ b_i;
    assign c4_o = c4_int;
    // n4: cast operand in a High_conn of a child instance
    leaf2_94 #(.W(W)) u_leaf (.p_i(W'(b_i)), .p_o(c5_o));
    // n5: nested cast
    assign c6_o = W'(W'(a_i));
  end
endmodule

module g2_ctx94_top (
  input logic [7:0] a8, b8, input logic [15:0] a16, b16,
  output logic [7:0] o1,o2,o3,o4,o5,o6, output logic [15:0] p1,p2,p3,p4,p5,p6
);
  ch2_94 #(.W(8))  u_a (.a_i(a8), .b_i(b8), .c1_o(o1),.c2_o(o2),.c3_o(o3),.c4_o(o4),.c5_o(o5),.c6_o(o6));
  ch2_94 #(.W(16)) u_b (.a_i(a16),.b_i(b16),.c1_o(p1),.c2_o(p2),.c3_o(p3),.c4_o(p4),.c5_o(p5),.c6_o(p6));
endmodule
