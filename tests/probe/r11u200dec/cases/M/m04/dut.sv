module m04 #(parameter N = 2) (input logic [N-1:0] [N-1:0] [1:0] b, output logic o);
  logic [N-1:0] [N-1:0] v;
  assign o = b[0][0][0];
endmodule
