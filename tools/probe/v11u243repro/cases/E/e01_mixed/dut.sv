// § clsPropSpecPaNoFile243
// a specialization with a type argument followed by a value argument, and a value-only one
package p;
  class imp #(type T = int, int N = 2);
    T a[N];
  endclass
endpackage
import p::*;
class sb;
  imp #(byte, 3) m1;
  imp #(.T(shortint)) m2;
  imp #(int, 4) m3;
endclass
module top;
  sb s;
endmodule
