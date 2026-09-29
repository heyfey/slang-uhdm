// § strLitPpEscIdShift224 (two escaped identifiers separated by a backtick, then a third after a blank run)
module top(output string o, output int k);
  initial begin
    o = "\p `\q  r\s t"; k = 3;
  end
endmodule
