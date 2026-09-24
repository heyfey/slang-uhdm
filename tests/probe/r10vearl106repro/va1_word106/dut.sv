// r10v106 va1_word106 — WORD-BOUNDARY widths for § genCaCastFoldAdjustSize106.
// `NumUtils::getMask(w)` is `~0ULL` for w >= 64; the patch mirrors that with
// `w >= 64 ? ~0ULL : (1<<w)-1`.  63 / 64 / 65 / 96 / 128 Lhs widths, and cast
// widths written both as a LITERAL (integer_typespec, masks) and as a PACKAGE
// PARAMETER (int_typespec, does not).  MEASUREMENT ONLY.
package pv1_106;
  parameter int unsigned P63  = 63;
  parameter int unsigned P64  = 64;
  parameter int unsigned P65  = 65;
  parameter int unsigned P8   = 8;
  parameter int unsigned P128 = 128;
endpackage

module va1_word106 (output logic o);
  logic [62:0]  l63a, l63b;
  logic [63:0]  l64a, l64b, l64c;
  logic [64:0]  l65a, l65b;
  logic [95:0]  l96a;
  logic [127:0] l128a, l128b;

  // Lhs 63 — the mask must be 2^63-1, not ~0
  if (1) begin : w_63lit assign l63a = 64'(64'hFFFF_FFFF_FFFF_FFFF); end
  if (1) begin : w_63par assign l63b = pv1_106::P64'(64'hFFFF_FFFF_FFFF_FFFF); end
  // Lhs 64 — the sentinel collision in caLhsAdjustSize68
  if (1) begin : w_64lit assign l64a = 64'(64'hFFFF_FFFF_FFFF_FFFF); end
  if (1) begin : w_64par assign l64b = pv1_106::P64'(64'hFFFF_FFFF_FFFF_FFFF); end
  if (1) begin : w_64sm  assign l64c = pv1_106::P8'(6'h3F); end
  // Lhs 65 — past the word, getMask still ~0
  if (1) begin : w_65lit assign l65a = 64'(64'hFFFF_FFFF_FFFF_FFFF); end
  if (1) begin : w_65par assign l65b = pv1_106::P65'(64'hFFFF_FFFF_FFFF_FFFF); end
  // Lhs 96 / 128
  if (1) begin : w_96    assign l96a  = pv1_106::P8'(6'h3F); end
  if (1) begin : w_128a  assign l128a = pv1_106::P128'(64'hFFFF_FFFF_FFFF_FFFF); end
  if (1) begin : w_128b  assign l128b = 8'(6'h3F); end

  assign o = l64a[0];
endmodule
