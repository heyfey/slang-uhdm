// § varSelIdxHpLeafByPath306
package vsp;
  class cel; int fv; endclass
  class box;
    cel bin[];
    int one_d[8];
    int two_d[4][4];
    int q;
  endclass
  class holder; box bx; endclass
  class probe;
    box bb; holder hd; cel got; int n; int r;
    int two_d[4][4];
    function int f(int x); return x; endfunction
    function void probes();
      got = bb.bin[two_d[bb.q][hd.bx.q] + two_d[1][bb.q]];
    endfunction
  endclass
endpackage
module top; endmodule
