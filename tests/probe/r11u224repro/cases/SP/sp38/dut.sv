// § strLitPpEscIdShift224
module top(input logic [1:0] s, output string o);
  always_comb case (s) 2'd0: o = "a\nb` c"; default: o = "d"; endcase
endmodule
