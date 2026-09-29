// § strLitPpEscIdShift224 (a double backtick followed by a blank after the escaped identifier)
module top(output string o, output int k);
  initial begin
    o = "a\n `` y"; k = 1;
  end
endmodule
