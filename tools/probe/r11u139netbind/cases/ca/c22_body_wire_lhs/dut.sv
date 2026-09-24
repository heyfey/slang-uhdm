module top(input p, output a);
  wire w;
  assign w = 1'b0;
  wire v;
  assign v = p | 1'b0;
  assign a = w ^ v;
endmodule
