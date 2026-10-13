// § nestShapeThroughVarSel308
package vsp;
  class bin_c; int fv; endclass
  class box; bin_c bin[16]; int q; endclass
  class probe; box bb; int two_d[4][4]; int n; int got; bit c;
    function void probes(); got = bb.bin[c ? two_d[1][bb.q] : n].fv; got = bb.bin[two_d[two_d[0][bb.q]][1]].fv; endfunction
  endclass
endpackage
module top; endmodule
