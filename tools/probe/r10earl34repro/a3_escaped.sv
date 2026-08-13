// r10earl34 ARM A3 — THE ESCAPED-IDENTIFIER / MAXIMAL-HAZARD ARM.
//
// STANDING OPS RULE: "escaped identifiers on any name-reading gate (a
// NAME-REWRITE law is maximal hazard: an escaped identifier may contain
// brackets/digits — build those cells)".  § hpMixedIdxPkgFold34 REWRITES a
// hier_path DISPLAY NAME, so these are the cells that decide whether the
// splice is safe.
//
// The law splices by SOURCE OFFSET (`rawTextPkgFold` takes the symbol's own
// SourceRange), never by matching the symbol's NAME inside the index text.
// That is what makes these cells safe, and these cells are what prove it:
//
//   \p[0]   — an escaped package localparam whose SPELLING CONTAINS BRACKETS.
//             A name-matching splice would corrupt the surrounding text or
//             mis-parse the index; an offset splice replaces exactly its span.
//   \p8     — an escaped package localparam whose spelling ENDS IN A DIGIT and
//             collides with the VALUE another cell substitutes.
//   \m[0]   — the same bracketed spelling, but declared in the MODULE: it must
//             stay spelled out (the negative control for the whole law).
//   \a.b    — an escaped name containing a DOT, the hier_path separator.
//
// A name-keyed implementation fails cells 1/2/4 loudly; an offset-keyed one
// passes all four.

package e34c_pkg;
  localparam int \p[0]  = 3;
  localparam int \p8    = 5;
  localparam int \a.b   = 6;
  localparam int Plain  = 7;
endpackage

typedef struct packed {
  logic [3:0] q;
} e34c_inner_t;

typedef struct packed {
  e34c_inner_t base;
  logic [15:0] a_source;
} e34c_cfg_t;

module a3_escaped import e34c_pkg::*; (
  output logic [31:0] o
);

  localparam int \m[0] = 2;   // MODULE-scope escaped, bracketed: must NOT fold

  e34c_cfg_t [15:0] arr;

  // ---- bracketed escaped PACKAGE localparam, bare, base position ---------
  assign arr[\p[0] ].base.q = 4'h0;          // -> golden [3]

  // ---- digit-suffixed escaped PACKAGE localparam ------------------------
  assign arr[\p8 ].base.q = 4'h1;            // -> golden [5]

  // ---- dotted escaped PACKAGE localparam --------------------------------
  assign arr[\a.b ].base.q = 4'h2;           // -> golden [6]

  // ---- bracketed escaped MODULE localparam: THE NEGATIVE CONTROL --------
  assign arr[\m[0] ].base.q = 4'h3;          // -> golden keeps \m[0]

  // ---- escaped package param inside a COMPOUND index --------------------
  assign arr[\p[0] +1].base.q = 4'h4;        // -> golden [3 + 1]

  // ---- plain package localparam alongside, same array -------------------
  assign arr[Plain].base.q = 4'h5;           // -> golden [7]

  // ---- an escaped ARRAY name with a package index (the base is escaped) --
  e34c_cfg_t [15:0] \arr[x] ;
  assign \arr[x] [Plain].base.q = 4'h6;      // -> golden \arr[x] [7]

  assign o = 32'h0;

endmodule
