module sub #(parameter N = 2) (input wire [N-1:0] [3:0] b, output wire [N-1:0] [3:0] d);
  assign d = b;
endmodule
module m08 (input logic [2:0][3:0] b, output logic [2:0][3:0] d);
  sub #(3) u (.b(b), .d(d));
endmodule
