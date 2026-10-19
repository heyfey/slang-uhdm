// § classPropBasedLitKept410
package p;
class C;
  static int a = 16'hBEEF;
  const int b = 3'o7;
  shortint c = 4'd9;
endclass
endpackage
module top; p::C c = new; endmodule
