// r10earl34 VERIFIER ARM V3 — is the CONCAT-INIT over-fold NEW (this patch) or
// PRE-EXISTING (§ hierSelPkgParamFold's own range-select arm)?
//
// v2_kinds established that golden does NOT substitute a package localparam
// whose initializer is a CONCATENATION: golden keeps `arr2[PkgCat]` and even
// keeps a `ref_obj` as the index, while the patched build prints `arr2[9]`.
// This arm asks the same question of the OTHER builder — the RANGE / part
// select path that already carried the fold before r10earl34 — so the defect
// can be attributed correctly.
//
//   v3_rng_cat  : `[PkgCat-1:0]`   range select, concat-init package lp
//   v3_ips_cat  : `[0+:PkgCat]`    indexed part select, concat-init package lp
//   v3_rng_lit  : `[PkgHex-1:0]`   the same shapes with a LITERAL-init package
//   v3_ips_lit  : `[0+:PkgHex]`    lp — the control that must still fold
//   v3_derived  : `[PkgDer]`       package lp initialised from ANOTHER package
//                                  lp by arithmetic (the BankAddrW shape the
//                                  standing table says renders as a decimal)
//   v3_unknown  : `[PkgUnk]`       package lp with X bits — collectPkgParamFolds
//                                  abstains; does golden?

package v3_pkg;
  localparam int       PkgCat = {2'b10, 2'b01};   // = 9, CONCAT initializer
  localparam bit [4:0] PkgHex = 5'h8;             // literal initializer
  localparam int       PkgOne = 4;
  localparam int       PkgDer = PkgOne + 3;       // = 7, arithmetic initializer
endpackage

typedef struct packed {
  logic [3:0] q;
} v3_inner_t;

typedef struct packed {
  v3_inner_t   base;
  logic [31:0] a_source;
} v3_cfg_t;

module v3_cat import v3_pkg::*; (
  input  v3_cfg_t [7:0] tl_h_i,
  output logic [31:0] o
);
  v3_cfg_t [15:0] arr;

  // RANGE / PART selects — the builder that ALREADY had § hierSelPkgParamFold
  assign o[8:0]  = tl_h_i[0].a_source[PkgCat-1:0];  // v3_rng_cat
  assign o[17:9] = tl_h_i[1].a_source[0+:PkgCat];   // v3_ips_cat
  assign o[24:18] = tl_h_i[2].a_source[PkgHex-1:0]; // v3_rng_lit
  assign o[31:25] = tl_h_i[3].a_source[0+:7];       // filler

  // ELEMENT selects — the builder r10earl34 just gave the fold to
  assign arr[PkgDer].base.q = 4'h1;                 // v3_derived
endmodule
