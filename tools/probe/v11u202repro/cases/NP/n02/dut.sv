// § modPkgGenericSpecNamedBare202
package p;
  class c #(int W = 1);
  endclass
  class b #(type T = int);
  endclass
endpackage
module n02;
  if (1) begin : g
    p::c #(8) h;
  end
  function automatic void f();
    p :: b #(byte) k = new;
  endfunction
  p::c #( 4 ) h1, h2 = new;
endmodule
