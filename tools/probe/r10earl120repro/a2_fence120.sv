// r10earl120 — ARM a2_fence120: THE FENCE.  Every row here must be
// BYTE-IDENTICAL between the two binaries: the stamp copies the SOURCE
// typespec's `vpiInstance`, so a source with no home stamps nothing, and a
// read that § genCaTopLoopParamPaCopy105 never answers is never touched.
//
//   f_loc   a module localparam read in a part-select bound (source has no home)
//   f_par   a module PARAMETER read (source has no home)
//   f_gv    a genvar read (not a parameter at all)
//   f_gen   a GEN-SCOPE-local localparam read (gen-local, not the outer param)
//   f_plain a package-origin read OUTSIDE any select/param window in the DEF
//           listing (module body, no instance) — pass 105's window is the
//           elaborated instance
//   f_str   a STRUCT-typed package parameter: its elaborated Rhs is not a
//           constant, so the copy is declined (pass 105's own fence)
package p120f_pkg;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } t120f_t;
  localparam t120f_t S0 = '{a: 4'h3, b: 4'h4};
  localparam int W0 = 5;
endpackage

module a2_sub120f #(parameter int unsigned M = 4, parameter int unsigned PW = 3) (
  input  logic [31:0] a,
  output logic [7:0]  o  [M],
  output logic [7:0]  q  [M]
);
  localparam int unsigned LOCW = 4;
  localparam p120f_pkg::t120f_t SCOPY = p120f_pkg::S0;

  // f_plain: the DEF listing's own module body.
  logic [7:0] plain;
  assign plain = a[0 +: LOCW];

  for (genvar i = 0 ; i < M ; i++) begin : gen_f
    localparam int unsigned GENW = 2;      // f_gen
    logic [7:0] r1, r2, r3, r4;
    assign r1 = a[0 +: LOCW];              // f_loc
    assign r2 = a[0 +: PW];                // f_par
    assign r3 = a[0 +: (GENW + 1)];        // f_gen
    assign r4 = a[i +: 2];                 // f_gv
    assign o[i] = r1 ^ r2 ^ r3 ^ r4;
    assign q[i] = {4'h0, SCOPY.a};         // f_str
  end
endmodule

module a2_fence120 (input logic [31:0] a,
                    output logic [7:0] o [4], output logic [7:0] q [4]);
  a2_sub120f #(.M(4), .PW(3)) u_f (.a(a), .o(o), .q(q));
endmodule
