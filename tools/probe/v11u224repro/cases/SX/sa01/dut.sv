// § strLitPpEscIdShift224
`define SET(x) x = 1;
module top(output string o, output int k);
  initial begin
    o = "a\nb` c"; `SET(k)
  end
endmodule
