// § strLitContLineSpan220
package p;
  parameter string P = "abc \
   def";
endpackage
module top(output string o);
  initial o = p::P;
endmodule
