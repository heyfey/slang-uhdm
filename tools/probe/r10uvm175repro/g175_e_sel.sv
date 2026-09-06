// r10uvm175 arm E — SELECT SHAPES and ROOTS that are NOT the plain indexed
// step: part selects, multi-dimensional steps, an index whose own text carries
// a dot, and the two IMPLICIT CLASS HANDLE roots.  Every one of these is a
// FENCE, and each was measured on golden before the law was written.
package echo_wharf;
  class plank;
    string knots[$];
    function new(); endfunction
    function int nail(); return 0; endfunction
  endclass
  class hullbase;
    plank inherited[$];
    function new(); endfunction
  endclass
  class raft extends hullbase;
    plank decks[$];
    plank slab[4][4];
    plank tier[4];
    logic [7:0] bus;
    logic [7:0] lanes [4];
    int cut[$];
    string wanted;
    int single;
    plank helper;
    function void trim(int cursor);
      // s_1dim: the ordinary single-dimension step (the POSITIVE control)
      cut = decks[cursor].knots.find_index() with (item == wanted);
      // s_2dim: TWO written dimensions on component 0
      cut = slab[1][cursor].knots.find_index() with (item == wanted);
      // s_dotidx: the index text itself carries a DOT
      cut = decks[helper.nail()].knots.find_index() with (item == wanted);
      // s_thisrecv: a `this.`-rooted indexed receiver (FENCE)
      cut = this.decks[cursor].knots.find_index() with (item == wanted);
      // s_superrecv: a `super.`-rooted indexed receiver (FENCE)
      cut = super.inherited[cursor].knots.find_index() with (item == wanted);
      // s_fixed: a fixed unpacked array root
      cut = tier[cursor].knots.find_index() with (item == wanted);
      // s_partsel: a PART SELECT on a packed vector, no method (FENCE)
      bus = lanes[cursor][7:4];
      // s_idxpart: an INDEXED part select on a packed vector (FENCE)
      bus = lanes[cursor][cursor +: 4];
      // s_nowiththis: the `this.` root WITHOUT a with clause — r10uvm74's own
      // pre-existing cell, recorded so this arm can prove it does not move
      single = this.decks[cursor].knots.size();
    endfunction
  endclass
endpackage
