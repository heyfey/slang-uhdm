// r10earl10 pass-10 witness: DEF-VIEW GEN BLOCK declaration of a variable
// whose type is a NAMED (typedef) type.  Golden stmt-ifies it as a Rhs-less
// assignment (op 82, blocking) whose Lhs is a struct_var / enum_var / ...
// carrying a ref_typespec onto the RESOLVED typespec; we emit NOTHING (the
// def-gen DataDeclaration arm only handles scalar/int/ranged-logic/unpacked).
// Corpus: tlul_socket_m1.sv:90 `tlul_pkg::tl_h2d_t hreq_fifo_i;` inside
// `for (genvar i...) begin : gen_host_fifo` -> 2 Earlgrey AllModules heads.
package vap;
  typedef struct packed {
    logic [3:0] a;
    logic       b;
  } vs_t;
  typedef enum logic [1:0] { E0, E1, E2 } ve_t;
  typedef logic [7:0] vl_t;
  typedef struct packed { logic [1:0] q; } vq_t;
endpackage

module va
  import vap::*;
#(
  parameter int M = 2
) (
  input  logic clk_i,
  output logic [3:0] o
);
  typedef struct packed { logic [2:0] m; } loc_t;

  vap::vs_t top_v;

  for (genvar i = 0; i < M; i++) begin : gen_b
    // A: QUALIFIED package struct typedef  (the corpus shape)
    vap::vs_t sA;
    // B: BARE (wildcard-imported) package struct typedef
    vs_t sB;
    // C: package ENUM typedef
    vap::ve_t sC;
    // D: package VECTOR typedef
    vap::vl_t sD;
    // E: MODULE-LOCAL struct typedef
    loc_t sE;
    // F: control — plain ranged logic (already emitted today)
    logic [3:0] sF;
    // G: control — plain scalar
    logic sG;
    // H: packed array over a package struct typedef (existing arm)
    vap::vq_t [1:0] sH;
    assign sF = i;
    assign sG = 1'b0;
  end

  assign o = top_v.a;
endmodule
