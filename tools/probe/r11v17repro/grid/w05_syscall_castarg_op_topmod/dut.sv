// The same CAST argument at TOP level (no child instance).
module top #(parameter int unsigned W = 8)(input logic [W-1:0] b_i, output logic [W-1:0] o);
  logic [W-1:0] m_var;
  assign m_var = b_i;
  if (W > 2) begin : gen_k
    assign o = $signed(W'(m_var)) ^ 8'd1;
  end
endmodule
