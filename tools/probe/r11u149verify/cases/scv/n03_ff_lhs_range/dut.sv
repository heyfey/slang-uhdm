// § sysArgUnaryConstSelToken140v
module dut(input logic clk, input logic [3:0] a, input logic [7:0] d, output logic [7:0] q);
  always_ff @(posedge clk) q[$bits(-a)-1:0] <= d[3:0];
endmodule
