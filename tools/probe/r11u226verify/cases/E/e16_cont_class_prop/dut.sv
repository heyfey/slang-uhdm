// § strLitContLineSpan220 — a continued string literal as a class property initializer and as a static class property initializer
package p;
  class c;
    string s = "prop \
line";
    static string t = "stat \
two";
  endclass
endpackage
module top;
  import p::*;
endmodule
