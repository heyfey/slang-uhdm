// r10uvm180 arm E — THE IMPORT GRAPH.
// Two hops, a diamond, a re-export and a SHADOW, so the clone's alias target is
// not decidable from the typedef's name alone.  The spellings deliberately
// collide across packages (`marl_lt` exists in three of them) — a grid that
// names everything after one package would confirm itself.
package ea180_alpha;
  typedef logic [9:0] marl_lt;
  function automatic int unsigned marl_alpha(marl_lt bed);
    marl_lt seam;
    seam = bed;
    if (seam[0]) begin
      marl_lt lens;
      lens = seam >> 1;
      seam = lens;
    end
    return int'(seam);
  endfunction
endpackage

// hop 1: beta imports alpha AND declares its own same-named typedef, so the
// clone it carries of `marl_alpha` must still alias alpha's object, bare.
package ea180_beta;
  import ea180_alpha::*;
  typedef bit [9:0] marl_lt;                     // SHADOWS alpha's spelling
  function automatic int unsigned marl_beta(marl_lt bed);
    marl_lt seam;
    seam = bed;
    begin
      marl_lt lens;
      lens = seam + 1;
      seam = lens;
    end
    return int'(seam);
  endfunction
endpackage

// hop 2: gamma imports beta only, and so re-clones beta's own body AND the
// copy of alpha's body that beta carries.
package ea180_gamma;
  import ea180_beta::*;
endpackage

// the diamond: delta imports BOTH sides.
package ea180_delta;
  import ea180_alpha::*;
  import ea180_beta::*;
endpackage

module ea180_top;
  import ea180_alpha::*;
  ea180_alpha::marl_lt tier;
  ea180_beta::marl_lt  course;
  int unsigned tally;
  initial begin
    tier   = 10'h155;
    course = 10'h0aa;
    tally  = marl_alpha(tier) + ea180_beta::marl_beta(course);
  end
endmodule
