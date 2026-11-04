module m02 #(parameter N = 2, parameter W = 4) (a, b, d);
  input  logic [N-1:0] [W-1:0]  b;
  input logic a;
  output logic [1:0] [3:0]      d;
  assign d = b;
endmodule
