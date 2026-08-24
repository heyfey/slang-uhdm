// r10v123 arm E — the WRITTEN-SPELLING fence, widened.  ONE typedef reached
// four ways in the SAME method: bare, package-scoped, through a wildcard
// import, and through an explicit import; plus a bare cast whose target name is
// shadowed by nothing but reached from a nested block.
package larch123_pkg;
  typedef bit   [7:0] larch_v_t;
  typedef logic [5:0] larch_l_t;
endpackage

package maple123_pkg;
  import larch123_pkg::*;
  import larch123_pkg::larch_l_t;
  function automatic int maple_mix(int qq);
    larch_v_t a1, a2;
    larch_l_t b1, b2;
    a1 = larch_v_t'(qq);                    // BARE (wildcard-visible)
    a2 = larch123_pkg::larch_v_t'(qq);      // SCOPED
    b1 = larch_l_t'(qq);                    // BARE (explicit import)
    b2 = larch123_pkg::larch_l_t'(qq);      // SCOPED
    begin : inner
      larch_v_t c1;
      c1 = larch_v_t'(qq + 1);              // BARE, nested block
      a1 = a1 + c1;
    end
    return int'(a1) + int'(a2) + int'(b1) + int'(b2);
  endfunction
endpackage

module larch_top;
  import larch123_pkg::*;
  larch_v_t w1, w2;
  assign w1 = larch_v_t'(3);
  assign w2 = larch123_pkg::larch_v_t'(4);
  initial begin
    int rr;
    rr = maple123_pkg::maple_mix(2) + int'(w1) + int'(w2);
  end
endmodule
