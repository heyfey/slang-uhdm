// § strLitContLineSpan220
package p;
  localparam string S = "pk \
str";
endpackage
module top(output string o);
  initial o = p::S;
endmodule
