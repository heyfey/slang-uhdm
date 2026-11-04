// § coverClockedPropExprIsClock424
module top(input bit clk, input read, input write);
  assume property (@(posedge clk) read |-> write);
  c1: cover property (@(posedge clk) read ##1 write) $display("hit");
endmodule
