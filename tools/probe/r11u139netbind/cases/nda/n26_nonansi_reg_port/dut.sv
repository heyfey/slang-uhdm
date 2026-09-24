// § ndaLeftmostLeafElab139
module top(clk, p, y);
  input clk, p; output y;
  reg r;
  always @(posedge clk) r <= p;
  wire x = r;
  assign y = x;
endmodule
