// r10uvm94 arm a2 — NON-CLASS homes, DOTTED TARGETS.
// The law only reaches a hier_path, and a hier_path only forms when the SELECTED
// object is dotted; an index that is dotted over a LOCAL target builds a plain
// (indexed_)part_select with no hier_path at all (arm cells t1/t2 prove it).
// Interfaces, module hierarchy, struct/union members, generate and task homes;
// plus the base kinds whose `decompileHelper` row this pass does NOT touch
// (bit_select, cast, $bits, operation, constant, ref_obj) so the gate is
// exercised from BOTH sides.  MEASUREMENT-ONLY.
package rp94;
  parameter int RW94 = 7;
  parameter int RQ94 = 3;
  typedef struct packed { logic [15:0] tag; logic [15:0] len; } Head94;
endpackage

interface bus94 ();
  logic [511:0] lane;
  logic [63:0]  slot;
  int           anchor;
  int           reach;
endinterface

module leaf94 (input logic clk94);
  logic [255:0] pool;
  int           mark94;
  logic [31:0]  taken;
  always_comb taken = pool[mark94 +: 32];
endmodule

module m94_homes;
  import rp94::*;
  typedef struct packed { logic [63:0] body; logic [15:0] where; } Cell94;
  typedef union  packed { logic [31:0] flat; Head94 split; } Mix94;

  bus94  chan94 ();
  leaf94 kid94 (.clk94(1'b0));

  Cell94 cel;
  Mix94  mux94;
  Head94 hd94;
  logic [63:0] fetch;
  logic [1023:0] tape;
  logic [31:0] nibs [0:7];
  int    here94;
  int    step94;
  logic [31:0] scratch;
  localparam int LOCP94 = 23;

  // t1/t2  DOTTED INDEX over a LOCAL target -- NO hier_path is built at all
  always_comb fetch = tape[cel.where +: 17];
  always_comb fetch = tape[chan94.anchor +: 18];

  // b1  INTERFACE target, base = interface member (hier_path)
  always_comb fetch = chan94.lane[chan94.anchor +: 48];
  // b2  interface target, MINUS
  always_comb fetch = chan94.slot[chan94.reach -: 22];
  // b3  MODULE-HIERARCHY target and base
  always_comb fetch = kid94.pool[kid94.mark94 +: 30];
  // b4  interface target, base = STRUCT member of a local
  always_comb fetch = chan94.lane[cel.where +: 19];
  // b5  interface target, base = packed-UNION member
  always_comb fetch = chan94.lane[mux94.split.len +: 21];
  // b6  interface target, base = ELEMENT SELECT of a local array (bit_select)
  always_comb fetch = chan94.lane[nibs[2] +: 25];
  // b7  interface target, base = a CAST of a member (no prettyPrint row)
  always_comb fetch = chan94.lane[int'(cel.where) +: 27];
  // b8  interface target, base = $bits of a TYPE
  always_comb fetch = chan94.lane[$bits(Head94) +: 20];
  // b9  interface target, base = plain LOCAL -- must NOT move
  always_comb fetch = chan94.lane[here94 +: 26];
  // b10 interface target, base = package PARAMETER -- must NOT move
  always_comb fetch = chan94.lane[rp94::RW94 +: 24];
  // b11 struct target, base = struct member, width = module localparam
  always_comb fetch = cel.body[cel.where +: LOCP94];
  // b12 struct target, base = member, width = package parameter
  always_comb scratch = {29'b0, hd94.tag[hd94.len +: rp94::RQ94]};
  // b13 FENCE: part_select over a dotted member, constant bounds
  always_comb fetch = chan94.lane[95:32];
  // b14 FENCE: bit_select over a dotted member with a member index
  always_comb scratch = {31'b0, chan94.lane[chan94.anchor]};
  // b15 FENCE: part_select over a dotted member with an operation bound
  always_comb fetch = chan94.slot[rp94::RW94 - 1:0];
  // b16 interface target, base = an OPERATION over a member -- must NOT move
  always_comb fetch = chan94.lane[cel.where * 2 + 1 +: 28];

  // b17..b19 a GENERATE-scope home
  genvar gi94;
  generate
    for (gi94 = 0; gi94 < 2; gi94++) begin : gblk94
      logic [63:0] gout94;
      always_comb gout94 = chan94.lane[cel.where +: 26];
      always_comb gout94 = chan94.lane[gi94 * 8 +: 26];
      always_comb gout94 = kid94.pool[kid94.mark94 -: 18];
    end
  endgenerate

  // b20 a TASK home with an LVALUE member-base select on a dotted target
  task automatic pushb94();
    chan94.lane[cel.where +: 12] = 12'hABC;
    step94 = here94;
  endtask
  initial pushb94();
endmodule
