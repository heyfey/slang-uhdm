// § strLitPpEscIdShift224
package p;
  parameter string P = "a\nb` c";
endpackage
module top(output string o);
  assign o = p::P;
endmodule
