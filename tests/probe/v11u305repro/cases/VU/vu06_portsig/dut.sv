// § ifCaUnsizedRhsClonePerInst305
interface bif(input logic clk);
  logic [7:0] arr[2];
  assign arr[0] = {8{clk}} & '1;
endinterface
module top(input logic c);
  bif b0(c);
  bif b1(.clk(c));
endmodule
