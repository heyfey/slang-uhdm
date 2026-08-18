// r10uvm92 VERIFIER arm b3 — SITE 3 (method-call receiver) + the ABSTAIN paths.
`define IDXM (u + 1)
`define NAMEM u
package rcv;
  class item;
    int gv;
    function int get(); return gv; endfunction
    function int getw(int a); return a; endfunction
  endclass
  class mid;
    item slotq[];
    item grid[4][4];
    int  q;
  endclass
  class top; mid md; item direct[]; endclass

  class rig;
    top    tp;
    mid    md2;
    item   pool[];
    item   mesh[4][4];
    int    u, v;
    int    lut[8];
    int    \odd-name ;


    function int calls();
      int r;
      // c01 receiver, plain operation index
      r = pool[u-1].get();
      // c02 receiver, index is a bit_select (renders EMPTY inside)
      r = pool[u + lut[2]].get();
      // c03 receiver, index is a 2-D var_select
      r = pool[u + mesh[1][2].gv].get();
      // c04 receiver, TWO-DIM select on the receiver itself
      r = mesh[u-1][v+2].get();
      // c05 receiver, deep path, two selects
      r = tp.md.slotq[u*3].get();
      // c06 receiver, deep path, one plain one operation
      r = tp.direct[u].get();
      // c09 receiver, method with args
      r = pool[u%4].getw(7);
      // c10 receiver, index from a MACRO
      r = pool[`IDXM].get();
      // c11 receiver, index name from a MACRO
      r = pool[`NAMEM + 1].get();
      // c12 receiver, ternary with hier operands
      r = pool[u ? tp.md.q : v].get();
      // c13 receiver, unbounded queue bound
      r = pool[u - 1].get();
      // c14 nested call: receiver index is another call
      r = pool[u + tp.md.q].getw(pool[v-1].get());
      // c15 CONTROL: plain index, must not move
      r = pool[u].get();
      // c16 CONTROL: constant index
      r = pool[5].get();
      // c17 receiver whose index is a wildcard-eq (no row)
      r = pool[u ==? v].get();
      // c18 concat index at the receiver
      r = pool[{2'b1, 2'b0}].get();
      return r;
    endfunction

    // d: NON-receiver sites with macros and escapes
    function void others();
      // d01 index entirely from a macro
      md2.slotq[`IDXM] = null;
      // d02 macro name inside an operation
      md2.slotq[`NAMEM * 2] = null;
      // d04 deep chain: 6 nested operations
      md2.slotq[((((u+1)*2)-3)/4)%5] = null;
      // d05 2-D var_select of an escaped base
      md2.slotq[u + mesh[1][2].gv] = null;
      // d06 a queue bound
      md2.slotq[u + lut[1]] = null;
    endfunction
  endclass
endpackage
