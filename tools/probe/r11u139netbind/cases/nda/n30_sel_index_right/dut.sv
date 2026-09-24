module top(input [1:0] idx, input [3:0] v, input p, output y);
  wire w = p & v[idx];
  assign y = w;
endmodule
