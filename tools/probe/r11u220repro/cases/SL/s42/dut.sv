// § strLitContLineSpan220
module top(output string o);
  localparam string P = "abc \
def";
  initial o = P;
endmodule
