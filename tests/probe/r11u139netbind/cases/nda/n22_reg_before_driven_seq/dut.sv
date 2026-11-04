// § ndaLeftmostLeafElab139
module top(input clk, input p, output y);
  reg r;
  always @(posedge clk) r <= p;
  wire w = r;
  assign y = w;
endmodule
