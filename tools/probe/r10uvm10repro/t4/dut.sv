package p;
  class Inner;
    int x;
  endclass
  typedef Inner pkg_inner_t;
endpackage

module top;
  import p::*;
  function pkg_inner_t mf();
    pkg_inner_t ml;
    return ml;
  endfunction
  initial begin
    pkg_inner_t bl;
    Inner bd;
    bl = null;
    bd = null;
  end
  always_comb begin
    pkg_inner_t al;
    al = null;
  end
endmodule
