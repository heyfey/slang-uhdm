// § macroBodyTrailingComment125
`define W 4// c
module top(input logic [3:0] a, output logic [3:0] o);
  localparam int P = `W; assign o = a + P;
endmodule
