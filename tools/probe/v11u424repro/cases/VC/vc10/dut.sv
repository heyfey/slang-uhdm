// § coverClockedPropExprIsClock424
program prg(input bit clk, input logic a);
  cover property (@(posedge clk) a) $display("x");
endprogram
module top; bit c; logic a; prg p(c, a); endmodule
