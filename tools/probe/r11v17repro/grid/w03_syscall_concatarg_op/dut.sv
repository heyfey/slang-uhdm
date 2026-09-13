// $signed's argument is a CONCAT (the c08/c26 shape).
module ch #(parameter int unsigned W = 8)(input logic [W-1:0] b_i, input logic s_i, output logic [W:0] o);
  logic [W-1:0] m_var; logic sg;
  assign m_var = b_i; assign sg = s_i;
  if (W > 2) begin : gen_k
    assign o = $signed({sg, m_var}) ^ 9'd1;
  end
endmodule
module top(input logic [7:0] b8, input logic s, output logic [8:0] q);
  ch #(.W(8)) u_a(.b_i(b8), .s_i(s), .o(q));
endmodule
