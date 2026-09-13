// The cast is nested inside a CONCAT that is the $signed argument.
module ch #(parameter int unsigned W = 8)(input logic [W-1:0] b_i, output logic [W:0] o);
  logic [W-1:0] m_var;
  assign m_var = b_i;
  if (W > 2) begin : gen_k
    assign o = $signed({1'b0, W'(m_var)}) ^ 9'd1;
  end
endmodule
module top(input logic [7:0] b8, output logic [8:0] q);
  ch #(.W(8)) u_a(.b_i(b8), .o(q));
endmodule
