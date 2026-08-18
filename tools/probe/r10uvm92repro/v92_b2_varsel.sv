// r10uvm92 VERIFIER arm b2 — the var_select BOUNDARY: how many select levels,
// over which base kind, packed vs unpacked, becomes a UHDM var_select?
package vsp;
  class cel; int fv; endclass
  class box;
    cel bin[];
    int one_d[8];
    int two_d[4][4];
    int three_d[2][3][4];
    logic [31:0] pv;
    logic [3:0][7:0] pk2;
    logic [1:0][3:0][7:0] pk3;
    logic [31:0] uv[4];
    int q;
  endclass
  class holder; box bx; endclass

  class probe;
    box    bb;
    holder hd;
    cel    got;
    int    n;
    int    one_d[8];
    int    two_d[4][4];
    int    three_d[2][3][4];
    logic [31:0] pv;
    logic [3:0][7:0] pk2;
    logic [1:0][3:0][7:0] pk3;
    logic [31:0] uv[4];

    function void probes();
      // p01 ONE level, unpacked ElementSelect      -> bit_select?
      got = bb.bin[n + one_d[2]];
      // p02 TWO levels, unpacked                    -> var_select?
      got = bb.bin[n + two_d[1][2]];
      // p03 THREE levels, unpacked
      got = bb.bin[n + three_d[1][2][3]];
      // p04 ONE level, packed vector bit select
      got = bb.bin[n + pv[5]];
      // p05 ONE level, packed vector range select   -> part_select
      got = bb.bin[n + pv[7:4]];
      // p06 TWO levels, packed 2-D
      got = bb.bin[n + pk2[1][2]];
      // p07 THREE levels, packed 3-D
      got = bb.bin[n + pk3[1][2][3]];
      // p08 TWO levels, unpacked-of-packed, second is a RANGE
      got = bb.bin[n + uv[1][7:4]];
      // p09 TWO levels, unpacked-of-packed, second is a BIT
      got = bb.bin[n + uv[1][7]];
      // p11 TWO levels over a MEMBER ACCESS base    -> hier_path (EMPTY)
      got = bb.bin[n + bb.two_d[1][2]];
      // p13 ONE level over a MEMBER ACCESS base
      got = bb.bin[n + bb.one_d[2]];
      // p15 TWO levels with OPERATION indices
      got = bb.bin[n + two_d[n+1][n-1]];
      // p16 TWO levels, second index an empty-rendering operand
      got = bb.bin[n + two_d[1][bb.q]];
      // p17 TWO levels with an indexed part select second
      got = bb.bin[n + uv[1][3+:4]];
      // p18 TWO levels, whole thing negated
      got = bb.bin[-two_d[1][2]];
      // p19 TWO levels inside a concat
      got = bb.bin[{two_d[1][2], n}];
      // p21 TWO levels as a sys-call argument
      got = bb.bin[n + $clog2(two_d[1][2])];
      // p22 TWO levels inside inside{}
      got = bb.bin[n inside {two_d[1][2], 4}];
      // p23 TWO levels nested in a ternary
      got = bb.bin[n ? two_d[1][2] : three_d[0][1][2]];
      // p24 controls that must not move
      got = bb.bin[n + 1];
      got = bb.bin[n - bb.q];
    endfunction
  endclass
endpackage
