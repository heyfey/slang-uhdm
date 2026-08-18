// r10uvm94 arm a3 -- the gate's SECOND accepted width kind, and its edges.
//
// hpIdxBaseHierPathEmpty94 renders the width through decompileHelper's
// `constant` (VpiDecompile) and `ref_obj` (VpiName) rows.  A width that stays a
// ref_obj is hierSelWidthOvParamNoFold's shape: an OVERRIDABLE module parameter
// in the port list has no settled value at definition-compile time, so neither
// Surelog nor we substitute it.  The arm also carries the shapes the gate must
// REFUSE (operation width, $bits width) and a dotted target whose name has NO
// trailing bracket group at all.  MEASUREMENT-ONLY.
interface deep94;
  logic [127:0] room94;
endinterface

interface plane94;
  logic [255:0] bank94;
  logic [31:0]  stamp94;
  deep94        inner94 ();
endinterface

module m94_wref #(parameter int SRAMAW94 = 9, parameter int SHIFT94 = 4) ();
  typedef struct packed { logic [31:0] fld94; logic [15:0] off94; } Rec94;
  plane94 duo94 ();
  Rec94 rec94;
  logic [63:0] out94;
  int   idle94;

  // w1  base = struct member (hier_path), width = OVERRIDABLE module parameter
  always_comb out94 = duo94.bank94[rec94.off94 +: SRAMAW94];
  // w2  same, MINUS direction, a second overridable parameter
  always_comb out94 = duo94.bank94[rec94.off94 -: SHIFT94];
  // w3  base = member, width = an OPERATION -- the gate must REFUSE
  always_comb out94 = duo94.bank94[rec94.off94 +: SRAMAW94 + 2];
  // w4  base = member, width = $bits(<type>)
  always_comb out94 = duo94.bank94[rec94.off94 +: $bits(Rec94)];
  // w5  base = member, width = a LITERAL -- accepted
  always_comb out94 = duo94.bank94[rec94.off94 +: 13];
  // w6  a dotted target with NO select at all: no bracket group in the name
  always_comb out94 = {32'b0, duo94.stamp94};
  // w7  a dotted target with a BIT select only (bracket group, not an ips)
  always_comb out94 = {63'b0, duo94.bank94[rec94.off94]};
  // w8  a dotted target with a trailing PART select (the R2 fence)
  always_comb out94 = duo94.bank94[47:16];
  // w9  three-deep dotted target, member base, literal width
  always_comb out94 = duo94.inner94.room94[rec94.off94 +: 11];
  // w10 idle read so rec94.fld94 is not dead
  always_comb idle94 = int'(rec94.fld94);
endmodule
