// § fixedOuterAssocInnerReg223
module dut (input logic clk, input logic [7:0] d, output logic [7:0] q);
  logic [7:0] mem [2][int];
  always_ff @(posedge clk) q <= d;
endmodule
