// § strLitContLineSpan220
module top(output string o);
  initial $display("x=%0d \
y", 1, "a \
b");
endmodule
