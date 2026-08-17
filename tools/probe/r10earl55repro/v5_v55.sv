// v55 adversarial arm 5 — the last places a WIDTH-1 fold could still want the
// ranged logic_typespec: four-state and high-Z operands, a replication COUNT
// that over-fills one bit (truncation), a count of 1 on a wider operand, a
// width-1 param living beside a WIDE one that IS read reducingly (the a3
// split at width 1), a width-1 param in a module instantiated from inside a
// generate-if, and a width-1 param in a module instantiated inside an
// interface.
// MEASURED (both views, both binaries): TO-GOLDEN 10 / AWAY-GOLDEN 0 /
// STILL-WRONG 0.  A TRUNCATING count ({2{1'b1}} into [0:0]) and a WIDER operand
// ({1{4'hA}} -> UINT:4, {2{2'b10}} -> UINT:2) match golden's VpiValue exactly,
// which is the operand-width rule stated by the law and now checked away from 1.
// gen-if and gen-for INSTANTIATED modules, and an interface localparam, all
// move.  The a3 split does NOT reappear at width 1: N1 beside a reducingly-read
// N15 stays int, and M1 stays int even when M1 ITSELF is the reduced one.
// NEW RESIDUE (V1), not named by the pass: a FOUR-STATE operand ({1{1'bx}},
// {1{1'bz}}) makes us emit NO typespec at all where golden emits int_typespec
// UINT:1.  Pristine == patched; the width-1 arm is never reached.
interface if5_55(input logic ext);
  localparam logic [0:0] IN = {1{1'b1}};
  logic w;
  assign w = ext ^ IN[0];
endinterface

module v5_v55(input logic ext);
  r0_v55 u_r0 (.o(), .ext(ext));
  r1_v55 u_r1 (.o(), .ext(ext));
  r2_v55 u_r2 (.o(), .ext(ext));
  r3_v55 u_r3 (.o(), .ext(ext));
  if5_55 u_if5 (.ext(ext));
  if (1) begin : g_on
    r4_v55 u_r4 (.o(), .ext(ext));
  end
  for (genvar g = 0; g < 2; g++) begin : g_lp
    r5_v55 u_r5 (.o(), .ext(ext));
  end
endmodule

// four-state and high-Z replicated operands at width 1
module r0_v55 (output logic o, input logic ext);
  localparam logic [0:0] FX = {1{1'bx}};
  localparam logic [0:0] FZ = {1{1'bz}};
  localparam logic [0:0] F0 = {1{1'b0}};
  assign o = ext;
endmodule

// a replication COUNT that over-fills the one bit, and a WIDER operand
module r1_v55 (output logic o, input logic ext);
  localparam logic [0:0] TR = {2{1'b1}};
  localparam logic [0:0] WO = {1{4'hA}};
  localparam logic [0:0] WC = {2{2'b10}};
  assign o = ext;
endmodule

// the a3 SPLIT at width 1: a wide neighbour that IS read reducingly
module r2_v55 (output logic o, input logic ext);
  localparam logic [0:0]  N1 = {1{1'b1}};
  localparam logic [14:0] N15 = {15{1'b1}};
  assign o = |N15;
endmodule

// the width-1 param ITSELF read reducingly next to an unread wide one
module r3_v55 (output logic o, input logic ext);
  localparam logic [0:0]  M1 = {1{1'b1}};
  localparam logic [14:0] M15 = {15{1'b1}};
  assign o = |M1;
endmodule

module r4_v55 (output logic o, input logic ext);
  localparam logic [0:0] GI = {1{1'b1}};
  assign o = ext ^ GI[0];
endmodule

module r5_v55 (output logic o, input logic ext);
  localparam logic [0:0] GL = {1{1'b1}};
  assign o = ext ^ GL[0];
endmodule
