// § modPkgGenericSpecNamedBare202
package p;
  class o; endclass
  class b #(type T = int);
    T v;
  endclass
endpackage
module top;
  p::b #(p::o) h = new;
  p::b #(byte) k = null;
endmodule
