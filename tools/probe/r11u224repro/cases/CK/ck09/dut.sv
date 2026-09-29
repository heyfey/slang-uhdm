// § strLitContOwnerEnd224
package p;
  string s = "abc \
def";
endpackage
module top(output string o);
  assign o = p::s;
endmodule
