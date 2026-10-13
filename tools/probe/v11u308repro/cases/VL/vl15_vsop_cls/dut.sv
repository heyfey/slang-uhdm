// § varSelIdxOpHpLeafByPath308
package vsp;
  class bin_c; int fv; endclass
  class box; bin_c bin[16]; int q; int bins[16]; endclass
  class probe; box bb; int two_d[4][4]; int n; int got;
    function int f(int a); return a; endfunction
    function void probes(); got = bb.bins[two_d[1][f(bb.q) + 1]]; got = bb.bins[two_d[n][-bb.q]]; got = bb.bins[two_d[1][$clog2(bb.q)]]; endfunction
  endclass
endpackage
module top; endmodule
