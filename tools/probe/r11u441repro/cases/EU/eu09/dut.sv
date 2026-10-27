// § emptySlotArgEndPrevTok441
module top;
  sequence s(x, y = 1'b1);
    x ##1 y;
  endsequence
  logic clk, a;
  assert property (@(posedge clk) s(a,
                                    ));
endmodule
