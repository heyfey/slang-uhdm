// $signed's argument is a BARE REF (the counter-witness shape).
module ch #(parameter int unsigned W = 8)(input logic [W-1:0] b_i, output logic [W-1:0] o);
  logic [W-1:0] m_var;
  assign m_var = b_i;
  if (W > 2) begin : gen_k
    assign o = $signed(m_var) ^ 8'd1;
  end
endmodule
module top(input logic [7:0] b8, output logic [7:0] q);
  ch #(.W(8)) u_a(.b_i(b8), .o(q));
endmodule
