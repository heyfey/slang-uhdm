// r10v180 arm B — THE NAMING FACES.  logic / bit / byte / int / integer /
// shortint / longint vs enum vs packed struct vs union vs a class handle,
// each bound in a clone body as a nested-block local AND as an expression
// operand.  Deliberately unlike each other in name, case, length and digits.
package Kiln7_PK;
  typedef logic  [13:0] Emberr14;
  typedef bit    [2:0]  soot3_T;
  typedef byte          FLUE_b;
  typedef int           draught_I;
  typedef integer       Vent99;
  typedef shortint      grate_s;
  typedef longint       Cinder_L;
  typedef enum bit [1:0] { ASH_q = 2'd0, PYRE_q = 2'd1 } quench_E;
  typedef struct packed { logic [3:0] lintel; bit clinker; } Hearth_S;
  typedef union  packed { logic [4:0] mantle;  bit [4:0] damper; } Bellows_U;

  class Tongs_c;
    int wedge;
    function new(); wedge = 3; endfunction
  endclass

  function automatic int unsigned faces_fn(Emberr14 spark);
    Emberr14  a0;
    a0 = spark;
    begin
      soot3_T   b1;
      FLUE_b    c2;
      draught_I d3;
      Vent99    e4;
      grate_s   f5;
      Cinder_L  g6;
      quench_E  h7;
      Hearth_S  i8;
      Bellows_U j9;
      Tongs_c   k10;
      b1 = 3'd1; c2 = 8'sd2; d3 = 3; e4 = 4; f5 = 5; g6 = 6;
      h7 = PYRE_q; i8.clinker = 1'b1; j9.mantle = 5'h1f; k10 = new();
      a0 = Emberr14'(int'(b1) + int'(c2) + d3 + int'(e4) + int'(f5) +
                     int'(g6) + int'(h7) + int'(i8.lintel) + int'(j9.damper) +
                     k10.wedge);
    end
    return int'(a0) + $bits(Emberr14'(a0));
  endfunction

  function automatic int unsigned agg_fn(Hearth_S grille);
    Hearth_S loam;
    loam = grille;
    begin
      Bellows_U nook;
      quench_E  puff;
      nook.mantle = 5'h03;
      puff = ASH_q;
      loam.lintel = 4'(int'(nook.damper) + int'(puff));
    end
    return int'(loam.lintel);
  endfunction
endpackage

package Kiln7_IMP;
  import Kiln7_PK::*;
endpackage

module Kiln7_top;
  import Kiln7_PK::*;
  Emberr14 blaze;
  Hearth_S trivet;
  int unsigned sum;
  initial begin
    blaze = 14'h0abc;
    trivet.lintel = 4'h5;
    sum = faces_fn(blaze) + agg_fn(trivet);
  end
endmodule
