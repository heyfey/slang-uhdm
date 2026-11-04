// § ppOutputLine166
`define ADD(x, y) ((x) + (y))
module top(input logic [3:0] a, input logic [3:0] b, output logic [4:0] y);
  assign y = `ADD(a,
                  b);
endmodule
