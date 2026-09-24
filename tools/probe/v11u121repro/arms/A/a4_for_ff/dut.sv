module dut #(parameter type idx_t = logic [1:0]) (input logic clk, input logic [3:0] v, output logic [7:0] q [2]);
  for (genvar k = 0; k < 2; k++) begin : g
    always_ff @(posedge clk) q[k] <= idx_t'({v[k], v[k+2]}) + idx_t'(1);
  end
endmodule
