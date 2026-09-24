module top(input p, output y);
  reg r1;
  wire w = r1;
  assign y = w ^ p;
endmodule
