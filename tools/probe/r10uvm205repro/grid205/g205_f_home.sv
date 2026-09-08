// r10uvm205 arm F — THE HOME MUST-STAY.  The declaring package alone, with a
// module that wildcard-imports it DIRECTLY (no intermediate package, so there
// is no subroutine CLONE at all).  Every home cell must keep its QUALIFIED
// alias target on both binaries.
package p205a_f;
  typedef bit [7:0] bt205;
  typedef logic [3:0] lt205;
  function automatic int fh205(input bt205 hio205[]);
    bt205 hloc205[];
    lt205 hlog205[];
    begin
      bt205 hblk205[];
      return hio205.size() + hloc205.size() + hlog205.size() + hblk205.size();
    end
  endfunction
endpackage

module g205_f_home;
  import p205a_f::*;
  bt205 m205[];
  int r205;
  initial r205 = fh205(m205);
endmodule
