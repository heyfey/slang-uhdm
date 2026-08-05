// r10earl7 witness tf — a PARAMETER-NAMED SIZE CAST in a package localparam.
// Census head (4 AllModules entries: hmac, hmac_core, sha2, sha2_pad — the
// class § importElemBareTdAlias advanced):
//   constant '' hmac_pkg.sv:11:51 {ct=9 sz=1 dec=1}  vs  operation '' :11:51
// i.e. hmac_pkg.sv:11
//   localparam logic [NumAlerts-1:0] AlertAsyncOn = NumAlerts'(1'b1);
// with `localparam int NumAlerts = 1;` right above it.  Golden folds the
// size cast to a plain constant UINT 1 at SIZE 1 (the cast width); we keep
// the cast operation.
package tfp;
  localparam int NumAlerts = 1;
  localparam int Wide      = 4;

  // SUBJECT — the hmac_pkg shape
  localparam logic [NumAlerts-1:0] AlertAsyncOn = NumAlerts'(1'b1);
  // Rows: a WIDER parameter-named cast, a literal-named cast, a cast over a
  // based literal and one over an unsized fill.
  localparam logic [Wide-1:0]      WideCast     = Wide'(1'b1);
  localparam logic [3:0]           LitCast      = 4'(1'b1);
  localparam logic [Wide-1:0]      WideHex      = Wide'(4'h5);
  localparam logic [Wide-1:0]      WideFill     = Wide'('1);
  // CONTROL — no cast at all
  localparam logic [NumAlerts-1:0] Plain        = 1'b1;
endpackage

// The failing view is the MODULE's MATERIALIZED wildcard-import copy (hmac,
// hmac_core, sha2 and sha2_pad all write `module X import hmac_pkg::*;`); the
// package's own two views are cmp-EQUAL without the import.
module tf import tfp::*; (
  input  logic       clk_i,
  output logic [3:0] z_o
);
  // NOTE: reading the package parameters from the module here folds each read
  // into the cont-assign operand tree and masks the law; the package's own
  // two views carry the subject.
  assign z_o = 4'h0;
endmodule
