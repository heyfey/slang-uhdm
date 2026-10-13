// § nestShapeThroughVarSel308
package vsp;
  class bin_c; int fv; endclass
  class box; bin_c bin[16]; int q; endclass
  class probe; box bb; int two_d[4][4]; int n; int got;
    function void probes(); bb.bin[two_d[n][bb.q]].fv = got; bb.bin[two_d[1][bb.q + n]].fv++; endfunction
  endclass
endpackage
module top; endmodule
