// § strLitPpEscIdShift224
module top(output string o);
  task automatic t(input string a, input int b); o = a; endtask
  initial t("a\nb` c", 3);
endmodule
