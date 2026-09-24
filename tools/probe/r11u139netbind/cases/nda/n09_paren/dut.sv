module top(input p, input q, input r, output y);
  wire w = (p | q) & r;
  assign y = w;
endmodule
