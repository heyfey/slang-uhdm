// v85 adversarial arm A4 — the ELAB leaf fold inside a kept operation:
// every declared type of the parameter the leaf names, overridden or not,
// package-qualified and bare, plus a gen-scope localparam leaf.
package u85_pkg;
  parameter int PKGSH = 3;
endpackage
module u85_child #(
  parameter int OVI = 5,
  parameter int NOVI = 5
) ();
  import u85_pkg::*;
  localparam int                  L_INT   = 6;
  localparam byte                 L_BYTE  = 7;
  localparam bit [7:0]            L_BIT   = 3;
  localparam logic [7:0]          L_LOG   = 4;
  localparam                      L_UNT   = 5;
  localparam bit signed [7:0]     L_SLOG  = 6;
  localparam integer              L_INTG  = 7;
  localparam shortint             L_SHORT = 2;
  localparam longint              L_LONG  = 3;
  localparam int                  L_CALC  = $clog2(256);

  localparam logic [31:0] m01 = ~(('h1 << L_INT)   - 1'b1);
  localparam logic [31:0] m02 = ~(('h1 << L_BYTE)  - 1'b1);
  localparam logic [31:0] m03 = ~(('h1 << L_BIT)   - 1'b1);
  localparam logic [31:0] m04 = ~(('h1 << L_LOG)   - 1'b1);
  localparam logic [31:0] m05 = ~(('h1 << L_UNT)   - 1'b1);
  localparam logic [31:0] m06 = ~(('h1 << L_SLOG)  - 1'b1);
  localparam logic [31:0] m07 = ~(('h1 << L_INTG)  - 1'b1);
  localparam logic [31:0] m08 = ~(('h1 << L_SHORT) - 1'b1);
  localparam logic [31:0] m09 = ~(('h1 << L_LONG)  - 1'b1);
  localparam logic [31:0] m10 = ~(('h1 << L_CALC)  - 1'b1);
  localparam logic [31:0] m11 = ~(('h1 << OVI)     - 1'b1);
  localparam logic [31:0] m12 = ~(('h1 << NOVI)    - 1'b1);
  localparam logic [31:0] m13 = ~(('h1 << PKGSH)   - 1'b1);
  localparam logic [31:0] m14 = ~(('h1 << u85_pkg::PKGSH) - 1'b1);
  localparam logic [31:0] m15 = ~(('h1 << (L_INT + OVI)) - 1'b1);
  localparam logic [31:0] m16 = ~(('h1 << $clog2(L_INT)) - 1'b1);
  localparam logic [31:0] m17 = ~({'h1, L_INT[3:0]});
endmodule
module va4_leaf85 ();
  u85_child #(.OVI(4)) u_ov ();
  u85_child            u_def ();
endmodule
