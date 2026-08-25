// r10v94 arm v1 -- gen scope inside an INSTANCE ARRAY, plus a gen scope
// containing an instance array.  MEASUREMENT ONLY.
module cha1_94 #(parameter int unsigned W = 8) (
  input  logic [W-1:0] a_i,
  input  logic [W-1:0] b_i,
  output logic [W-1:0] y_o
);
  logic [W-1:0] m_var;
  assign m_var = a_i;
  if (W > 2) begin : gen_a
    logic [W-1:0] g_loc;
    assign g_loc = b_i;
    assign y_o = W'(a_i) ^ W'(m_var) ^ W'(g_loc);
  end
endmodule

module v1_iarr94_top (
  input  logic [7:0] a8, b8,
  output logic [7:0] y0, y1, y2,
  output logic [7:0] z0
);
  logic [7:0] t_var;
  assign t_var = a8;
  // INSTANCE ARRAY of a module that owns a gen scope
  cha1_94 #(.W(8)) u_arr [0:2] (.a_i(a8), .b_i(b8), .y_o({y2,y1,y0}));
  // a gen scope that CONTAINS an instance array
  if (1) begin : gen_holder
    logic [7:0] h_loc;
    assign h_loc = b8;
    cha1_94 #(.W(8)) u_in [0:0] (.a_i(a8), .b_i(b8), .y_o(z0));
    // and a cast operand in the SAME gen scope, naming the top's var
  end
endmodule
