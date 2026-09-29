// § strLitPpEscIdShift224
`define M "a\nb` c"
module top(output string o);
  initial begin
    o = `M;
  end
endmodule
