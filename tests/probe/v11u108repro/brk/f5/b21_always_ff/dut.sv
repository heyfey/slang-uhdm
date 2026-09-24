module dut #(parameter type id_t = logic [1:0], localparam type rt_t = id_t [3:0]) (input logic clk, input logic [7:0] a, output logic [7:0] o);
  rt_t x;
  always_ff @(posedge clk) x <= a;
  assign o = x;
endmodule
