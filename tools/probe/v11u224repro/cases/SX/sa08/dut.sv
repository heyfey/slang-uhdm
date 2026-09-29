// § strLitPpEscIdShift224
module top(input logic x, output string o);
  initial begin
    assert (x) else $error("a\nb` c"); o = "q";
  end
endmodule
