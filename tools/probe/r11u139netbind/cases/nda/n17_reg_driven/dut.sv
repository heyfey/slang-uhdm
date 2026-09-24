module top(input p, output y);
  reg r;
  always @* r = p;
  wire w = r;
  wire x = r & p;
  assign y = w ^ x;
endmodule
