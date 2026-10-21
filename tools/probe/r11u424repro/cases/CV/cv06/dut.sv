// § coverClockedPropExprIsClock424
module top(input bit clk, input read, input write);
  default clocking cb @(posedge clk); endclocking
  cover property (read |-> write) $display("c");
  restrict property (read);
endmodule
