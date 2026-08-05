// vq.sv — pass 13.  TWO experiments on the bare-imported range-bound family.
//
// EXP-1 (the size law behind flash_ctrl:310 / top_pkg:8).  vp.sv row B showed
// golden folds `[NA:0]` to a size-32 constant where we emit size 64, while
// row A `[NA-1:0]` is size 64 on BOTH sides.  Hypothesis: it is not "bare
// imported" at all — a PLAIN parameter-reference bound carries the
// PARAMETER'S OWN type size; an ARITHMETIC bound is a 64-bit computed value.
// Rows P* vary the parameter's home scope and declared type with a PLAIN
// bound, rows Q* are the arithmetic twins.
//
// EXP-2 (the (a) shape: golden CONSTANT, ours ref_obj).  hmac.sv:25 is
// `input alert_rx_t [NumAlerts-1:0] alert_rx_i` — the element type is a
// STRUCT TYPEDEF, not a `logic` vector.  Row S is that row.
package vqp;
  parameter int      PI  = 4;      // int
  parameter          PU  = 5;      // untyped
  parameter logic [7:0] PL = 6;    // packed vector
  parameter byte     PB  = 7;      // byte
  typedef struct packed { logic a; logic b; } vq_t;
endpackage

module vqa import vqp::*; #(
  parameter int MP = 3
) (
  input  logic [PI:0]        pi_i,   // P1 bare imported, int,    PLAIN
  input  logic [vqp::PI:0]   pq_i,   // P2 qualified,     int,    PLAIN
  input  logic [MP:0]        pm_i,   // P3 module param,  int,    PLAIN
  input  logic [PU:0]        pu_i,   // P4 bare imported, untyped,PLAIN
  input  logic [PL:0]        pl_i,   // P5 bare imported, logic8, PLAIN
  input  logic [PB:0]        pb_i,   // P6 bare imported, byte,   PLAIN
  input  logic [PI-1:0]      qi_i,   // Q1 bare imported, int,    ARITH
  input  logic [MP-1:0]      qm_i,   // Q3 module param,  int,    ARITH
  input  vq_t  [PI-1:0]      s_i,    // S  STRUCT TYPEDEF element, ARITH
  input  vq_t  [PI:0]        t_i,    // T  STRUCT TYPEDEF element, PLAIN
  output logic               o
);
  localparam int LI = 9;
  logic [LI:0] lw;                   // P7 module localparam, PLAIN
  assign o = (|pi_i) & (|pq_i) & (|pm_i) & (|pu_i) & (|pl_i) & (|pb_i)
           & (|qi_i) & (|qm_i) & (|s_i) & (|t_i) & (|lw);
endmodule

module vqtop;
  logic o;
  vqa u (.o(o));
endmodule
