// § modPkgGenericSpecNamedBare202
package p;
  class o; endclass
  class c #(parameter int W = 4);
    logic [W-1:0] v;
  endclass
  class b #(type T = int);
    T v;
  endclass
endpackage
module top;
  p::b #(p::o) h;
endmodule
