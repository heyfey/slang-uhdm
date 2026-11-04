// § propAndOrUnparented420
module top;
  logic clk, a, b, c, d;
  assert property (@(posedge clk) (a |-> b) and (c |-> d));
endmodule
