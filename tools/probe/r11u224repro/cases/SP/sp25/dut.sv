// § strLitPpEscIdShift224
`define SET(x) x = "a\nb` c";
module top(output string o);
  initial begin
    `SET(o)
  end
endmodule
