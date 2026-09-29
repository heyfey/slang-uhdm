// § strLitPpEscIdShift224
module top(output string o);
  initial begin
    o = "x\ y`";
  end
endmodule
