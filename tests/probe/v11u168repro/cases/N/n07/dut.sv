// § ppOutputCol166
`define ADD(a, b) ((a) + (b))
module top(input logic [3:0] a, input logic [3:0] b, output logic [4:0] y, output logic [4:0] z);
  assign y = `ADD (a, b);
  assign z = `ADD(  a  ,  b  ) + 1;
endmodule
