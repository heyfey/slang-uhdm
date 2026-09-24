// § macroBodyTrailingComment125
`define W 4 // c
`define V `W + 1 // d
module top(input logic [3:0] a, output logic [3:0] o);
  localparam int P = `V; assign o = a + P;
endmodule
