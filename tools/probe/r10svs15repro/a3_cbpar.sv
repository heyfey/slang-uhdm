// r10svs15 ARM a3 — THE OVER-FIRE ARM.  Every cell here exists because the
// implementation this pass lands keys "the DEF" by the clocking block's SYNTAX
// NODE, and a syntax node is shared by things a def is not:
//
//   e1 — ONE parameterized interface at TWO parameter values plus a REPEAT of
//        the first value.  The clocking declaration's syntax node is the SAME for
//        all three, but they are three different bodies (two different
//        parameterizations).  If golden's "first elaborated instance" is per
//        PARAMETERIZATION, keying by syntax over-fires; if it is per syntax, it
//        does not.  THIS CELL DECIDES IT.
//   e2 — TWO named clocking blocks in ONE interface, array-instantiated: the key
//        must separate the blocks, not just the interface.
//   e3 — a cb whose event is a BARE identifier (`@(clock)`, no edge): the ref is
//        not wrapped in a posedge operation, so the ref walk must reach it.
//   e4 — a DEFAULT clocking block, array-instantiated.  A `default` block is
//        emitted by emitScopeClocking, NOT by emitNamedClockingBlocks, so this is
//        the CONTROL that says whether the law's carrier is "clocking blocks" or
//        specifically "NAMED clocking blocks".
`timescale 1ns/1ns

interface e1_if #(parameter int W = 8) (input bit clock);
  logic [W-1:0] d;
  clocking cb@(posedge clock);
    output d;
  endclocking
endinterface

interface e2_if(input bit clock, input bit clk2);
  logic d;
  clocking cba@(posedge clock);
    output d;
  endclocking
  clocking cbb@(negedge clk2);
    output d;
  endclocking
endinterface

interface e3_if(input bit clock);
  logic d;
  clocking cb@(clock);
    output d;
  endclocking
endinterface

interface e4_if(input bit clock);
  logic d;
  default clocking cb@(posedge clock);
    output d;
  endclocking
endinterface

module top();
  bit Clock, Clk2;
  e1_if #(8)  e8(Clock);
  e1_if #(16) e16(Clock);
  e1_if #(8)  e8b(Clock);
  e2_if       e2a[3](Clock, Clk2);
  e3_if       e3a[3](Clock);
  e4_if       e4a[3](Clock);
endmodule
