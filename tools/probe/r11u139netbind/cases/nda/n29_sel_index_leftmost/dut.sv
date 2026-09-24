module top(input [1:0] idx, input [3:0] v, input p, output y);
  wire w = v[idx] & p;
  assign y = w;
endmodule
