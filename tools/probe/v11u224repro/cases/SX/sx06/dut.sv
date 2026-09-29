// § strLitPpEscIdShift224
module top(input int x, output string o);
  initial begin
    $display("a\nb` c %0d", x); o = "z";
  end
endmodule
