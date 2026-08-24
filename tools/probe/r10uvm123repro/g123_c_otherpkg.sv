// r10uvm123 arm C — a package function of a DIFFERENT package casts package
// A's vector typedef; and A's own function casts it (the home-package arm the
// emitter already models).
`define WidC_123 6
package cedar123_a;
  typedef bit   [`WidC_123-1:0] cone_BT;
  typedef logic [`WidC_123-1:0] Cone_lt;
  function automatic int homefn(int y);
    cone_BT hb; Cone_lt hl;
    hb = cone_BT'(y);
    hl = Cone_lt'(y);
    return 4;
  endfunction
endpackage

package cedar123_b;
  import cedar123_a::*;
  function automatic int awayfn(int y);
    cone_BT ab; Cone_lt al;
    ab = cone_BT'(y);
    al = Cone_lt'(y);
    return 5;
  endfunction
endpackage

module cedar123_top;
  import cedar123_b::*;
  int r;
  initial r = awayfn(2);
endmodule
