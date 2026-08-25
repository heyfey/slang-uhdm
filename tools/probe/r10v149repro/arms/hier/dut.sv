// v149 arm 5 -- THE MEMBER REACHED THROUGH A HIER PATH AND A SELECT CHAIN.
// This is the r10uvm143 / r10uvm147 boundary: a select-chain path element's
// shape must not move because the member's TYPESPEC gained a wrapper.
package Psi_pkg;
  typedef struct {
    string chainArgs[$];
    logic [15:0] chainWord[$];
    int    chainTag;
  } chain_rec_t;

  class ChainHolder;
    chain_rec_t heldRec;
    function void poke(int idx);
      heldRec.chainTag = heldRec.chainWord[idx][7:0];
    endfunction
  endclass
endpackage

module Psi_leaf;
  import Psi_pkg::*;
  chain_rec_t leafRec;
  int    grabbed;
  initial begin
    grabbed = leafRec.chainWord[2][11:4];
    foreach (leafRec.chainArgs[i])
      grabbed = grabbed + i;
  end
endmodule

module hier_top;
  import Psi_pkg::*;
  Psi_leaf i_deep ();
  int reachedFromTop;
  initial reachedFromTop = i_deep.leafRec.chainWord[0][3:0];
endmodule
