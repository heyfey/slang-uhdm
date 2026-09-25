// § ppOutputCol166
`define ID(x) x
module top(input logic [7:0] a, output logic [7:0] y);
  assign y = `ID(8'h 0f) + `ID(  a);
endmodule
