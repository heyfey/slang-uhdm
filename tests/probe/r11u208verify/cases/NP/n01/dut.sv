// § modPkgGenericSpecNamedBare202
package p;
  class C #(parameter int W = 4);
    logic [W-1:0] v;
  endclass
  class B #(type T = int);
    T v;
  endclass
endpackage
module top;
  p::C #() h1;
  p::C h2;
  p::B #() h3 = new;
  p::C #(3) h4, h5;
endmodule
