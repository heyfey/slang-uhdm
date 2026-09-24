// r10earl81 arm g3 — THE DIGIT-NORMALISATION EDGE OF THE BARE-DECIMAL FENCE.
// The shipped producer reads the override actual's RAW TEXT and normalises it
// (underscores dropped, leading zeros stripped) before building the constant,
// so the two spellings a bare decimal can take are measured against golden
// rather than assumed.  MEASUREMENT ONLY.
//
// GOLDEN, measured (ELAB port High_conn bit_select index):
//   .Z(007)  -> constant UINT:7  size 64 ct 9  vpiDecompile `7`   (zeros GONE)
//   .U(2_0)  -> constant UINT:20 size 64 ct 9  vpiDecompile `20`  (`_` GONE)
// and the patched emitter reproduces both EXACTLY, where pristine kept a
// `ref_obj` for each.  Widths are 32 bits so neither index is out of bounds —
// an -Windex-oob rejection would make the arm test nothing.
module leafz81 (input logic ib, output logic o);
  assign o = ib;
endmodule

module midz81 #(
  parameter int unsigned Z = 1,   // overridden with a LEADING-ZERO decimal
  parameter int unsigned U = 1    // overridden with an UNDERSCORED decimal
) (
  input  logic [31:0] w,
  output logic [1:0]  y
);
  leafz81 uZ (.ib(w[Z]), .o(y[0]));
  leafz81 uU (.ib(w[U]), .o(y[1]));
endmodule

module topz81 (input logic [31:0] w, output logic [1:0] y);
  midz81 #(.Z(007), .U(2_0)) iz (.w(w), .y(y));
endmodule
