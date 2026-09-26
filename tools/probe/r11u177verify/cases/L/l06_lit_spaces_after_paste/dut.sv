// § ppBasedLitWsAfter166
`define LIT(w, v) w``'h   v
module top(input logic [7:0] a, output logic [7:0] y, output logic [7:0] z);
  assign y = a ^ `LIT(8, F);
  assign z = a | 8'h  3;
endmodule
