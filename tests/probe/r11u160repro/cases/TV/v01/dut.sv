// § defNetTypeParamPackedVec160
module top #(parameter int unsigned W = 8, parameter int unsigned N = 1,
             parameter type addr_t = logic [W-1:0])
  (input logic clk_i, input logic en_i, input addr_t [N-1:0] d_i, output addr_t [N-1:0] q_o);
  addr_t [N-1:0] q;
  assign q_o = q;
  always_ff @(posedge clk_i) begin
    for (int i = 0; i < N; i++) if (en_i) q[i] <= d_i[i];
  end
endmodule
