// r10svs15 ARM a1 — ONE interface/module DEF PER CELL, each instantiated EXACTLY
// ONE WAY.  a1's question is "WHICH element of an array is the binding target,
// and which shapes carry the rule at all"; the confound of two instantiation
// SITES for one def is deliberately excluded and measured separately in a2.
//
// Every cell's clocking event is `@(posedge <sig>)` so the census key is
// `<view>.cb.<sig>` and the arms line up column for column with the witness.
`timescale 1ns/1ns

// c1 — THE WITNESS REPLICA: array[4], one ANSI header-port clock, a `default`
// skew line, and a modport carrying the clocking block.
interface c1_if(input bit clock);
  logic d;
  clocking cb@(posedge clock);
    default input #1 output #1;
    output d;
  endclocking
  modport OP(clocking cb, input clock);
endinterface

// c2 — the same shape with NO MODPORT AT ALL.  svs14 refuted "modport-connected"
// as a discriminator on its own carrier; this cell asks the question again here.
interface c2_if(input bit clock);
  logic d;
  clocking cb@(posedge clock);
    output d;
  endclocking
endinterface

// c3 — TWO refs in ONE clocking event.  Does EACH ref bind, or only the first?
interface c3_if(input bit clock, input bit rst);
  logic d;
  clocking cb@(posedge clock or negedge rst);
    output d;
  endclocking
endinterface

// c4 — the clock is a BODY variable, NOT a header port: is the TARGET's carrier
// (a header-port `bit_var` on the witness) part of the rule?
interface c4_if(input bit clock);
  bit lclk;
  logic d;
  clocking cb@(posedge lclk);
    output d;
  endclocking
endinterface

// c5 — NO clocking block: an `always @(posedge clock)` in the same position.
// ARM ITEM (f): a NON-cb signal ref inside an array element's home view.
interface c5_if(input bit clock);
  logic d;
  always @(posedge clock) d <= 1'b0;
endinterface

// c6 — a MODULE with a named clocking block, array-instantiated.  ARM ITEM (g),
// the module-scope twin.
module c6_mod(input bit clock);
  logic d;
  clocking cb@(posedge clock);
    output d;
  endclocking
endmodule

// c7 — a DESCENDING, NON-ZERO-BASED range `[5:2]`.  There is NO element [0], so
// "binds to element [0]" is not even statable here; the cell reads out whether
// the target is the LEFTMOST index (5) or the LOWEST (2).  ARM ITEM (b), and the
// answer to "what if [0] is culled".
interface c7_if(input bit clock);
  logic d;
  clocking cb@(posedge clock);
    output d;
  endclocking
endinterface

// c8 — the SCALAR twin.  ARM ITEM (d): expected UNBOUND on both sides.
interface c8_if(input bit clock);
  logic d;
  clocking cb@(posedge clock);
    output d;
  endclocking
endinterface

// c9 — the SMALLEST array, [2]: exactly one target and exactly one follower.
interface c9_if(input bit clock);
  logic d;
  clocking cb@(posedge clock);
    output d;
  endclocking
endinterface

// c10 — an ASCENDING NON-ZERO-BASED range `[2:5]`: leftmost and lowest are the
// SAME index here, so c7 and c10 together separate the two candidate rules.
interface c10_if(input bit clock);
  logic d;
  clocking cb@(posedge clock);
    output d;
  endclocking
endinterface

// c11 — a TWO-DIMENSIONAL array `[2][2]`.  If the rule is "the first elaborated
// instance", a nested array has exactly one first; if it is per-row, it has two.
interface c11_if(input bit clock);
  logic d;
  clocking cb@(posedge clock);
    output d;
  endclocking
endinterface

module top();
  bit Clock, Rst;
  c1_if  c1a[4](Clock);
  c2_if  c2a[4](Clock);
  c3_if  c3a[4](Clock, Rst);
  c4_if  c4a[4](Clock);
  c5_if  c5a[4](Clock);
  c6_mod c6a[4](Clock);
  c7_if  c7a[5:2](Clock);
  c8_if  c8s(Clock);
  c9_if  c9a[2](Clock);
  c10_if c10a[2:5](Clock);
  c11_if c11a[2][2](Clock);
endmodule
