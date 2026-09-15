// r11u42 arm g2 — WILDCARD import, LVALUE position, procedural views,
// and the same index on a SELECTED base (the mixed builder, already folding).
package q42b;
  localparam int unsigned LP = 8;
  parameter  int unsigned PP = 4;
  typedef struct packed {
    logic [15:0] m;
    logic [3:0]  t;
  } s_t;
endpackage

module g2 (input logic [19:0] w20, input logic clk, output logic [63:0] o);
  import q42b::*;
  q42b::s_t v;
  q42b::s_t arr [0:1];
  q42b::s_t rv;
  localparam int unsigned MLP = 5;

  assign v = w20;

  // --- WILDCARD-imported package localparam, unqualified ----------------
  assign o[0] = v.m[LP-1];                 // d01 wildcard pkg localparam
  assign o[1] = v.m[PP-1];                 // d02 wildcard pkg parameter
  assign o[2] = v.m[LP];                   // d03 BARE wildcard read

  // --- LVALUE trailing select -------------------------------------------
  always_comb begin
    rv      = '0;
    rv.m[q42b::LP-1] = 1'b1;               // d04 lvalue, qualified pkg binop
    rv.m[MLP-1]      = 1'b1;               // d05 lvalue, module localparam
  end
  assign o[3] = rv.m[0];

  // --- procedural RVALUE -------------------------------------------------
  logic q;
  always_comb begin
    q = v.m[q42b::LP-1];                   // d06 procedural rvalue
  end
  assign o[4] = q;

  // --- SELECTED base (the mixed builder) --------------------------------
  assign arr[0] = w20;
  assign arr[1] = w20;
  assign o[5] = arr[0].m[q42b::LP-1];      // d07 base select + trailing binop
  assign o[6] = arr[q42b::PP-4].m[3];      // d08 base-select index, pkg binop

  // --- function body -----------------------------------------------------
  function automatic logic f(q42b::s_t a);
    return a.m[q42b::LP-1];                // d09 inside a function
  endfunction
  assign o[7] = f(v);
endmodule
