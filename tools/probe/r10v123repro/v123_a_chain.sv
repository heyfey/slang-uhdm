// r10v123 arm A — TYPEDEF-OF-TYPEDEF chains cast BARE from five positions.
// LAW S deliberately refuses an alias-of-alias a bare copy (TypeEmit note()).
// r10uvm123's cast pass has no such refusal: does golden clone here?
package alder123_pkg;
  parameter int ALDER_W = 9;
  typedef bit   [7:0]         alder_base_t;
  typedef alder_base_t        alder_mid_t;        // alias of an alias
  typedef alder_mid_t         alder_deep_t;       // three deep
  typedef logic [ALDER_W-1:0] alder_lbase_t;
  typedef alder_lbase_t       alder_lmid_t;
  function automatic int alder_home(int qq);
    alder_mid_t  mm;
    alder_lmid_t nn;
    alder_deep_t dd;
    mm = alder_mid_t'(qq);
    nn = alder_lmid_t'(qq);
    dd = alder_deep_t'(qq);
    return int'(mm) + int'(nn) + int'(dd);
  endfunction
  class AlderCls;
    function int am(int qq);
      alder_mid_t  mm2;
      alder_lmid_t nn2;
      mm2 = alder_mid_t'(qq);
      nn2 = alder_lmid_t'(qq);
      return int'(mm2) + int'(nn2);
    endfunction
  endclass
endpackage

package birch123_pkg;
  import alder123_pkg::*;
  function automatic int birch_use(int qq);
    alder_mid_t  m3;
    alder_lmid_t n3;
    m3 = alder_mid_t'(qq);
    n3 = alder_lmid_t'(qq);
    return int'(m3) + int'(n3);
  endfunction
endpackage

module alder_top;
  import alder123_pkg::*;
  alder_mid_t  wmod;
  alder_lmid_t xmod;
  assign wmod = alder_mid_t'(7);
  assign xmod = alder_lmid_t'(5);
  function automatic int alder_sub(int qq);
    alder_mid_t  m4;
    m4 = alder_mid_t'(qq);
    return int'(m4);
  endfunction
  initial begin
    int rr;
    rr = alder_home(3) + birch123_pkg::birch_use(4) + alder_sub(5);
  end
endmodule
