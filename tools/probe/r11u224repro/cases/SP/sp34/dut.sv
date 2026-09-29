// § strLitPpEscIdShift224
module top(output string o);
  initial begin
    o = "\na` \nb` c\\d";
  end
endmodule
