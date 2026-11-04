module sub #(parameter N = 2, parameter W = 4) (input logic [N-1:0] [W-1:0] b, output logic [N-1:0] [W-1:0] d);
  logic [N-1:0] [W-1:0] v;
  logic [1:0] [2:0] k;
  assign v = b;
  assign d = v;
endmodule
module m05 (input logic [2:0][4:0] b, output logic [2:0][4:0] d);
  sub #(.N(3), .W(5)) u (.b(b), .d(d));
endmodule
