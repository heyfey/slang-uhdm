// § ppOutputCol166
`define MUL(a, b) ((a) * (b))
`define ADD(a, b) ((a) + (b))
module top(input logic [3:0] a, input logic [3:0] b, input logic [3:0] c, output logic [8:0] y);
  assign y = `ADD(`MUL(a, b), c);
endmodule
