// § assocPromotedBoundAtBracket183: associative dimensions keyed by string, int, a class and a typedef in a package function's locals
package p;
  class key_c; endclass
  typedef logic [3:0] k_t;
  function automatic int f();
    int ms[string];
    byte mi[int];
    int mc[key_c];
    shortint mt[k_t];
    ms["a"] = 1;
    mi[3] = 8'd2;
    mt[4'd1] = 16'd3;
    return ms.size() + mi.size() + mc.size() + mt.size();
  endfunction
endpackage
module top; endmodule
