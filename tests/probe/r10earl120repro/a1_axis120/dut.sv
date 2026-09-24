// r10earl120 — ARM a1_axis120: THE AXIS of § `paPaCopyTsInstance120`.
//
// Every row is a bare read of a parameter that § genCaTopLoopParamPaCopy105
// answers with a COPY of the parameter's own elaborated `param_assign` Rhs
// constant (Surelog: `UHDM::clone_tree(param_ass->Rhs())`,
// CompileExpression.cpp:2918-2975).  The copy's typespec is minted field by
// field; this pass adds the field the mint was missing — `vpiInstance`, which
// `typespec::DeepCopy` (UHDM typespec.cpp:72-79) copies from the source.
//
// The DISCRIMINATOR is the ORIGIN of the parameter's declaration typespec:
//   * declared in a PACKAGE -> the source typespec is instanced at the
//     package, so the copy must be too;
//   * declared in the MODULE (localparam / parameter / genvar) -> the source
//     typespec has no home, so the copy must stay instance-less.
// Both legs sit in the SAME expression wherever possible, so one cell pair
// scores the stamp and its fence together.
package p120_pkg;
localparam int TL_AIW = 8;      // the head's shape: `localparam int` in a package
localparam int TL_AW  = 32;
localparam int TL_SZW = 4;
localparam bit [7:0] TL_MASK = 8'hF0;   // a NON-int source: pass 105 declines it
localparam TL_IMPL = 6;                 // IMPLICITLY typed package localparam
endpackage

module a1_sub120 #(parameter int unsigned M = 4, parameter int unsigned PW = 3) (
  input  logic [31:0] a,
  output logic [7:0]  o    [M],
  output logic [7:0]  o2   [M],
  output logic [7:0]  o3   [M]
);
  // r_pk   : origin is a PACKAGE parameter  -> the stamp
  // r_loc  : origin is a MODULE localparam  -> the fence (source has no home)
  // r_mod  : origin is a MODULE PARAMETER   -> the fence
  // r_impl : origin is an IMPLICITLY typed package localparam
  // r_msk  : origin is a `bit [7:0]` package localparam (non-int source)
  localparam int unsigned IDW   = p120_pkg::TL_AIW;
  localparam int unsigned STIDW = 2;
  localparam int unsigned MODW  = PW;
  localparam int unsigned IMPW  = p120_pkg::TL_IMPL;
  localparam int unsigned MSKW  = p120_pkg::TL_MASK[3:0];

  for (genvar i = 0 ; i < M ; i++) begin : gen_host_fifo
    // R1/R2: the head's own shape — a part-select bound whose two operands
    // are a package-origin read and a module-local one.
    logic [IDW-1:0] shifted_id;
    assign shifted_id = a[0 +: (IDW - STIDW)];
    assign o[i] = shifted_id;

    // R3: an indexed part-select with the DOWN direction, package origin.
    logic [7:0] down_sel;
    assign down_sel = a[IDW-1 -: 2];
    assign o2[i] = down_sel;

    // R4/R5: a module-PARAMETER origin and an implicitly typed package one,
    // in one operation.
    logic [7:0] mixed;
    assign mixed = a[0 +: (MODW + IMPW)];
    assign o3[i] = mixed;
  end
endmodule

module a1_axis120 (input logic [31:0] a,
                   output logic [7:0] o [4], output logic [7:0] o2 [4],
                   output logic [7:0] o3 [4],
                   output logic [7:0] p [2], output logic [7:0] p2 [2],
                   output logic [7:0] p3 [2]);
  // TWO instances of the same module: every instance must carry the stamp.
  a1_sub120 #(.M(4), .PW(3)) u_a (.a(a), .o(o),  .o2(o2),  .o3(o3));
  a1_sub120 #(.M(2), .PW(5)) u_b (.a(a), .o(p),  .o2(p2),  .o3(p3));
endmodule
