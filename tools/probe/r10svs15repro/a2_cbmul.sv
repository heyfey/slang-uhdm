// r10svs15 ARM a2 — ONE def, MORE THAN ONE instantiation SITE.
//
// a1 asks "which element of an ARRAY is the target".  a2 asks the prior question
// the witness cannot answer at all, because on the witness every interface def is
// instantiated exactly once: is the rule about the ARRAY, or about the DEF's
// FIRST ELABORATED INSTANCE anywhere in the design?  The two rules make OPPOSITE
// predictions on d1 (two scalars): "array" says both stay unbound, "first
// elaborated instance of the def" says `d1b` binds to `d1a`'s variable.
`timescale 1ns/1ns

// d1 — one def, TWO SCALAR instances, declared `d1a` then `d1b`.
interface d1_if(input bit clock);
  logic d;
  clocking cb@(posedge clock);
    output d;
  endclocking
endinterface

// d2 — one def, SCALAR declared FIRST, then an ARRAY.
interface d2_if(input bit clock);
  logic d;
  clocking cb@(posedge clock);
    output d;
  endclocking
endinterface

// d3 — one def, ARRAY declared FIRST, then a SCALAR.
interface d3_if(input bit clock);
  logic d;
  clocking cb@(posedge clock);
    output d;
  endclocking
endinterface

// d4 — one def, TWO ARRAYS.
interface d4_if(input bit clock);
  logic d;
  clocking cb@(posedge clock);
    output d;
  endclocking
endinterface

// d5 — one def, instantiated inside a SUBMODULE that is itself instantiated
// TWICE: the two elab views are in DIFFERENT parent scopes, so "same array" and
// "same parent" are both false and only "same def" survives.
interface d5_if(input bit clock);
  logic d;
  clocking cb@(posedge clock);
    output d;
  endclocking
endinterface

module d5_sub(input bit clock);
  d5_if u(clock);
endmodule

module top();
  bit Clock;
  d1_if  d1a(Clock);
  d1_if  d1b(Clock);
  d2_if  d2s(Clock);
  d2_if  d2arr[2](Clock);
  d3_if  d3arr[2](Clock);
  d3_if  d3s(Clock);
  d4_if  d4p[2](Clock);
  d4_if  d4q[2](Clock);
  d5_sub s1(Clock);
  d5_sub s2(Clock);
endmodule
