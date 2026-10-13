// § varSelIdxOpHpLeafByPath308
package vsp;
  class bin_c; int bin[16]; int fv; endclass
  class box; bin_c bin[16]; int ibin[16]; int q; int k; endclass
  class probe;
    box bb; int two_d[4][4]; int n; int got; int arr[16];
    function int f(int a); return a; endfunction
    function void probes();
      got = bb.ibin[n + two_d[1][bb.q + 1]];
    endfunction
  endclass
endpackage
module top; endmodule
