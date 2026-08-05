// r10earl7 witness te — LAW S at the ELEMENT of a materialized import copy's
// unpacked-array parameter.
// Census head (4 AllModules entries: hmac, hmac_core, sha2, sha2_pad):
//   logic_typespec 'sha_word_t' hmac_pkg.sv:17:11
//   vs             'hmac_pkg::sha_word_t' :17:11
// chain (from r10earl4h):
//   module_inst work@sha2 -> parameter 'CubicRootPrime' (the materialized
//   import copy) -> ref_typespec -> array_typespec hmac_pkg.sv:31:14 ->
//   ref_typespec -> logic_typespec 'sha_word_t'.
// Golden's element binding is the BARE per-declaration copy (LAW S); we bind
// the package's QUALIFIED listing object.  Our failRhs's parent chain is
// `package hmac_pkg ^ design`, which NAMES the object: the shared listing
// entry, not a copy.
// Corpus shape: `module sha2 import hmac_pkg::*;` + a package
// `localparam sha_word_t CubicRootPrime [64] = '{...};`
package tep;
  typedef logic [31:0] w_t;          // SCALAR ranged typedef — LAW S applies
  typedef logic        u_t;          // UNRANGED control
  typedef struct packed { logic [7:0] a; } s_t;   // AGGREGATE control (r7)

  localparam w_t ARR   [4] = '{32'h1, 32'h2, 32'h3, 32'h4};
  localparam u_t UARR  [2] = '{1'b0, 1'b1};
  localparam s_t SARR  [2] = '{'{a: 8'h1}, '{a: 8'h2}};
  localparam w_t SCAL      = 32'h5;   // scalar parameter control
endpackage

module te import tep::*; (
  input  logic        clk_i,
  input  logic [1:0]  sel_i,
  output logic [31:0] z_o
);
  w_t v;                              // variable binding (LAW S, already landed)
  assign v   = ARR[sel_i];
  assign z_o = v ^ SCAL ^ {24'b0, UARR[sel_i[0]]} ^ {24'b0, SARR[sel_i[0]].a};
endmodule
