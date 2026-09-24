module top(input [1:0] a, input [1:0] b, input [3:0] v, output y);
  wire w = v[a ^ b];
  assign y = w;
endmodule
