// § varSelIdxHpLeafByPath306
package vsp;
  class cel; int fv; endclass
  class box;
    cel bin[]; int one_d[8]; int two_d[4][4]; int three[2][2][2]; int q; box bb;
  endclass
  class holder; box bx; endclass
  class probe;
    box bb; holder hd; cel got; int n; int r;
    int two_d[4][4]; int three[2][2][2];
    function int f(int x); return x; endfunction
    function void probes();
      if (bb.bin[two_d[1][bb.q]] == null) r = 1;
    endfunction
  endclass
endpackage
module top; endmodule
