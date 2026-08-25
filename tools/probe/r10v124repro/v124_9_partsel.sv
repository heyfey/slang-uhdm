// r10v124 arm 9 — a PART-SELECT / SLICE receiver alone.
package Loft2;
  typedef int Chain[$];
  class Rung;
    Chain Steps[6];
    int   Bits[8];
    function void climb();
      Steps[2].push_back(901);
      Bits[3:5].reverse();
    endfunction
  endclass
endpackage
module Ladder;
  Loft2::Rung rg;
  initial begin rg = new(); rg.climb(); end
endmodule
