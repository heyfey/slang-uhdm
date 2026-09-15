// r11u42 arm g1 — the TRAILING member-select index text on a PLAIN base:
// which leaves fold into the hier_path NAME.
package q42;
  localparam int unsigned LP   = 8;
  parameter  int unsigned PP   = 4;
  localparam int unsigned CATP = {2'b10, 2'b01};   // concat-initialised
  localparam int unsigned REPP = {2{2'b01}};       // replication-initialised
  typedef struct packed {
    logic [15:0] m;
    logic [3:0]  t;
  } s_t;
  typedef struct packed {
    logic [1:0][7:0] pr;
    logic [3:0]      tg;
  } a_t;
  typedef struct packed {
    s_t inner;
    logic [3:0] z;
  } n_t;
endpackage

module g1 #(parameter int unsigned MPP = 3) (
    input  logic [19:0] w20,
    input  logic [19:0] w20b,
    input  logic [23:0] w24,
    output logic [63:0] o
);
  localparam int unsigned MLP = 5;
  q42::s_t v;
  q42::a_t av;
  q42::n_t nv;
  assign v  = w20;
  assign av = w20b;
  assign nv = w24;

  // --- index KINDS over a QUALIFIED package localparam ------------------
  assign o[0]  = v.m[q42::LP-1];          // c01 binop, pkg localparam
  assign o[1]  = v.m[q42::PP-1];          // c02 binop, pkg parameter
  assign o[2]  = v.m[q42::LP];            // c03 BARE pkg localparam
  assign o[3]  = v.m[-q42::LP+9];         // c04 unary + binop
  assign o[4]  = v.m[q42::LP*2-14];       // c05 two binops
  assign o[5]  = v.m[q42::LP>2 ? 1 : 0];  // c06 conditional
  assign o[6]  = v.m[q42::LP-q42::PP];    // c07 TWO pkg leaves
  assign o[7]  = v.m[q42::CATP-1];        // c08 concat-init pkg localparam
  assign o[8]  = v.m[q42::REPP-1];        // c09 repl-init pkg localparam
  assign o[9]  = v.m[$clog2(q42::LP)];    // c10 sys_func_call arg

  // --- NON-package scopes: must KEEP their identifier --------------------
  assign o[10] = v.m[MLP-1];              // c11 module localparam
  assign o[11] = v.m[MPP-1];              // c12 module parameter

  // --- ARRAY member (index selects a whole element) ----------------------
  assign o[19:12] = av.pr[q42::LP-7];     // c13 array member, pkg binop
  assign o[27:20] = av.pr[1];             // c14 array member, literal

  // --- path DEPTH 2 ------------------------------------------------------
  assign o[28] = nv.inner.m[q42::LP-1];   // c15 two members, pkg binop

  // --- literal control ---------------------------------------------------
  assign o[29] = v.m[7];                  // c16 literal
  assign o[30] = v.m[7-1];                // c17 literal binop
endmodule
