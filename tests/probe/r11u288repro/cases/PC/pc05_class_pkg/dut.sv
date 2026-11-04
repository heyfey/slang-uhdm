// § parenCastReadsCastSyntax288 — class methods, a package function, a class type parameter target and an imported package
package pp;
  typedef logic [3:0] n_t;
  function automatic int pf(input logic [7:0] a);
    return (int'(a)) + (n_t'(a));
  endfunction
  class c #(type T = int);
    int v;
    function void m(input logic [7:0] a);
      v = (int'(a)) + (T'(a));
      if ((int'(a)) > 2) v = (n_t'(v));
    endfunction
  endclass
endpackage
module top import pp::*; (input logic [7:0] x, output int y);
  c #(byte) h;
  always_comb y = pf(x) + (n_t'(x));
  initial begin h = new(); h.m(x); end
endmodule
