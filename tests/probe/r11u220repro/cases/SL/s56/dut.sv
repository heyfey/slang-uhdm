// § strLitContLineSpan220
module top(output string o);
  task automatic t(input string a); o = a; endtask
  initial t(.a("abc \
def"));
endmodule
