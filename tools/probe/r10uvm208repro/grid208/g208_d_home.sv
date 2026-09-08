// r10uvm208 arm D — THE HOME-ONLY CONTROL.  The declaring package alone, with
// a module that wildcard-imports it DIRECTLY, so there is no subroutine CLONE
// anywhere and no owner mask can ever read 1.  Every home cell keeps its
// QUALIFIED alias target and both binaries must produce a BYTE-IDENTICAL
// database in both views.  This is the arm that convicts a split that fires on
// a home declaration.
package p208a_f;
  typedef bit [7:0] bt208;
  typedef logic [3:0] lt208;
  function automatic int fh208(input bt208 hio208[]);
    bt208 hloc208[];
    lt208 hlog208[];
    int   a208 = 0;
    begin
      bt208 hblk208[];
      a208 += hblk208.size();
    end
    foreach (hio208[i208])
      a208 += int'(hio208[i208]);
    return a208 + hloc208.size() + hlog208.size();
  endfunction
  function automatic int fh2_208();
    bt208 h2_208[];
    return h2_208.size();
  endfunction
endpackage

module g208_d_home;
  import p208a_f::*;
  bt208 m208[];
  int r208;
  initial r208 = fh208(m208) + fh2_208();
endmodule
