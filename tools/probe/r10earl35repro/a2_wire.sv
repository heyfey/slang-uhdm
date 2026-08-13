// r10earl35 — the RESIDUE arm: isolate the explicit NET-KEYWORD axis.
//
// a1's `w_nest` cell (`input wire pkg::nest_t [3:0]`) is the one cell
// § pkgStructDeclArrFlat35 does NOT fix: an explicit net keyword makes
// `netTypeFor`'s own explicitDecl branch answer vpiWire FIRST, so the
// package-struct clause that carries the flatness exceptions is never reached.
//
// This arm answers the question that decides whether the residue is about the
// packed DIMENSION at all: is `wire pkg::nest_t x` (NO dimension) wrong too?
// If it is, the residue belongs to `netTypeFor`'s branch and has nothing to do
// with this pass's half; if only the dimensioned form is wrong, the residue is
// a missed descent like the one this pass fixed.
package e35b_pkg;
  typedef struct packed { logic [7:0] q; } flat_t;
  typedef struct packed {
    struct packed { logic       q; } a;
    struct packed { logic [8:0] q; } b;
  } nest_t;
  typedef struct packed { integer i; logic q; } atom_t;
endpackage

module e35b_dut (
  // ---- NO net keyword (the shape a1 already proved) ----
  input       e35b_pkg::nest_t       k_nest,      // no dim, no keyword
  input       e35b_pkg::nest_t [3:0] k_nest_d,    // dim,    no keyword

  // ---- explicit `wire` keyword ----
  input  wire e35b_pkg::flat_t       w_flat,      // FLAT, no dim
  input  wire e35b_pkg::nest_t       w_nest,      // NEST, no dim   <- THE Q
  input  wire e35b_pkg::flat_t [3:0] w_flat_d,    // FLAT, dim
  input  wire e35b_pkg::nest_t [3:0] w_nest_d,    // NEST, dim
  input  wire e35b_pkg::atom_t [3:0] w_atom_d,    // ATOM, dim

  // ---- a BODY net declaration with an explicit keyword ----
  output      e35b_pkg::nest_t [3:0] y_nest
);
  wire e35b_pkg::nest_t [3:0] bw_nest;
  wire e35b_pkg::flat_t [3:0] bw_flat;
  assign bw_nest = k_nest_d;
  assign bw_flat = w_flat_d;
  assign y_nest  = bw_nest;
endmodule

module e35b_top;
  e35b_pkg::nest_t            k_nest;
  e35b_pkg::nest_t [3:0]      k_nest_d;
  e35b_pkg::flat_t            w_flat;
  e35b_pkg::nest_t            w_nest;
  e35b_pkg::flat_t [3:0]      w_flat_d;
  e35b_pkg::nest_t [3:0]      w_nest_d;
  e35b_pkg::atom_t [3:0]      w_atom_d;
  e35b_pkg::nest_t [3:0]      y_nest;
  e35b_dut u_dut (.k_nest(k_nest), .k_nest_d(k_nest_d), .w_flat(w_flat),
                  .w_nest(w_nest), .w_flat_d(w_flat_d), .w_nest_d(w_nest_d),
                  .w_atom_d(w_atom_d), .y_nest(y_nest));
endmodule
