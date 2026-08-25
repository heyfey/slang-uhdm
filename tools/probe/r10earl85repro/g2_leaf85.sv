// r10earl85 g2 — THE LEAF FOLD inside an operation the shift-bail keeps.
// One localparam per row; every Rhs stays an operation (the '<<' left operand
// is an unsized based literal), so the only thing that varies is what the
// SHIFT AMOUNT reference becomes in the ELABORATED view.
package q85;
  localparam int PKGW = 3;
endpackage

module leaf85 #(
  parameter int OVI  = 4,          // overridden int
  parameter int NOVI = 5           // NOT overridden
) ();
  import q85::*;
  localparam int         L_INT   = 6;
  localparam byte        L_BYTE  = 7;
  localparam bit   [7:0] L_BIT   = 8;
  localparam logic [7:0] L_LOG   = 9;
  localparam             L_UNT   = 10;      // untyped
  localparam signed[7:0] L_SLOG  = 11;
  localparam integer     L_INTG  = 12;
  localparam shortint    L_SHRT  = 13;
  localparam longint     L_LONG  = 14;
  localparam int         L_CALC  = $clog2(256);   // 8, like WordsBitWidth

  localparam logic [31:0] r01 = ~(('h1 << L_INT)   - 1'b1);
  localparam logic [31:0] r02 = ~(('h1 << L_BYTE)  - 1'b1);
  localparam logic [31:0] r03 = ~(('h1 << L_BIT)   - 1'b1);
  localparam logic [31:0] r04 = ~(('h1 << L_LOG)   - 1'b1);
  localparam logic [31:0] r05 = ~(('h1 << L_UNT)   - 1'b1);
  localparam logic [31:0] r06 = ~(('h1 << L_SLOG)  - 1'b1);
  localparam logic [31:0] r07 = ~(('h1 << L_INTG)  - 1'b1);
  localparam logic [31:0] r08 = ~(('h1 << L_SHRT)  - 1'b1);
  localparam logic [31:0] r09 = ~(('h1 << L_LONG)  - 1'b1);
  localparam logic [31:0] r10 = ~(('h1 << L_CALC)  - 1'b1);
  localparam logic [31:0] r11 = ~(('h1 << OVI)     - 1'b1);
  localparam logic [31:0] r12 = ~(('h1 << NOVI)    - 1'b1);
  localparam logic [31:0] r13 = ~(('h1 << PKGW)    - 1'b1);
  localparam logic [31:0] r14 = ~(('h1 << q85::PKGW) - 1'b1);
  localparam logic [31:0] r15 = ~(('h1 << (L_INT + 1)) - 1'b1);
  localparam logic [31:0] r16 = ~(('h1 << L_INT) - L_INT);
  localparam logic [31:0] r17 = 'h1 << L_INT;
  localparam logic [31:0] r18 = ~('h1 << L_INT);
endmodule

module top85();
  leaf85 #(.OVI(4)) u_a ();
endmodule
