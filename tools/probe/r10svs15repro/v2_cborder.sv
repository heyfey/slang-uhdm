// r10svs15 VERIFIER arm v2 — "FIRST ELABORATED, DESIGN-WIDE" put under strain by
// making the first instance live at a DIFFERENT HIERARCHY LEVEL than the second,
// in BOTH orders.  If the rule were "top-level declarations first" rather than
// plain elaboration order, g1 and h1 would answer differently from each other in
// a way the implementer's a2/d5 (submodule twice, same level) cannot see.
//
//   g1  the FIRST instance is one level DOWN (gsub declared first), the second
//       at top          -> expect gs.gu to be the target, gtop to follow it
//   h1  the FIRST instance is at TOP (htop declared first), the second one
//       level down      -> expect htop to be the target, hs.hu to follow it
//   k1  the clocking block's event signal is DECLARED AFTER the block
//   k2  the def's first instance is inside a generate-if that is FALSE, so the
//       first LIVE instance is the second one textually
`timescale 1ns/1ns

interface g1_if(input bit clock);
  logic d;
  clocking cb@(posedge clock);
    output d;
  endclocking
endinterface

module gsub(input bit clock);
  g1_if gu(clock);
endmodule

interface h1_if(input bit clock);
  logic d;
  clocking cb@(posedge clock);
    output d;
  endclocking
endinterface

module hsub(input bit clock);
  h1_if hu(clock);
endmodule

interface k1_if(input bit clock);
  bit lclk;
  logic d;
  clocking cb@(posedge lclk);
    output d;
  endclocking
endinterface

interface k2_if(input bit clock);
  logic d;
  clocking cb@(posedge clock);
    output d;
  endclocking
endinterface

module top();
  bit Clock;
  gsub  gs(Clock);      // g1_if's FIRST instance is gs.gu, one level DOWN
  g1_if gtop(Clock);    // and its second is at top

  h1_if htop(Clock);    // h1_if's FIRST instance is at TOP
  hsub  hs(Clock);      // and its second is one level down

  k1_if k1a[3](Clock);

  generate
    if (0) begin : dead
      k2_if k2dead(Clock);   // NEVER elaborated
    end
  endgenerate
  k2_if k2a[2](Clock);       // the first LIVE k2_if instances
endmodule
