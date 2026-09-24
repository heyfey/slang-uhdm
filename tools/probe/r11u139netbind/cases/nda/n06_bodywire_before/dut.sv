module top(input p, output y);
  wire a;
  assign a = p;
  wire w = a & p;
  assign y = w;
endmodule
