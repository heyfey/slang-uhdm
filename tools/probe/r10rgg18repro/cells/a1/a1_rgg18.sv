// r10rgg18 grid A — MSB-SET gen-scope localparam FOLDS.
// Every row's fold value has the MSB of its DECLARED width set (or overflows
// it), which is the exact shape of the Rggen head
// (rggen_register_common.sv:33 START_ADDRESS, bit [ADDRESS_WIDTH-1:0]).
// Module-scope twins of every row are the CONTROL: they are rendered by a
// DIFFERENT emitter arm (ParamEmit) and must not move.
module a1_rgg18;
  parameter bit [6:0] OFF  = 7'h40;   // 64 -- MSB set in 7 bits
  localparam int      BW   = 4;

  // ---- MODULE-SCOPE CONTROLS (same shapes, different renderer) ----
  localparam bit [6:0]        MA = OFF + 7'(BW * 1);
  localparam bit signed [6:0] MB = OFF + 7'(BW * 1);
  localparam bit [7:0]        MD = 8'hC0 + 8'(1);
  localparam byte             ME = 8'hC0 + 8'(1);
  localparam bit [6:0]        MF = OFF + 7'd64;      // overflows 7 bits
  localparam bit [6:0]        MM = 7'h40 * 1 + 0;
  localparam bit [6:0]        MN = 0 - 7'd64 + 0;

  genvar g;
  generate
    for (g = 0; g < 2; ++g) begin : gb
      // A: THE HEAD'S EXACT SHAPE -- cast SEALS the `*`, so the structural
      // law answers UNSIGNED; the 7-bit bits read -64 signed.
      localparam bit [6:0]        A  = OFF + 7'(BW * g);
      // B: same bits, SIGNED declared type.
      localparam bit signed [6:0] B  = OFF + 7'(BW * g);
      // C: `int` -- 64 fits, no MSB set at 32 bits.
      localparam int              C  = OFF + 7'(BW * g);
      // D/J: 8-bit unsigned, MSB set.
      localparam bit [7:0]        D  = 8'hC0 + 8'(g);
      localparam logic [7:0]      J  = 8'hC0 + 8'(g);
      // E: `byte` -- SIGNED 8-bit, same bits as D.
      localparam byte             E  = 8'hC0 + 8'(g);
      // F/G1: the fold OVERFLOWS the declared width (128 in 7 bits).
      localparam bit [6:0]        F  = OFF + 7'd64;
      localparam bit [6:0]        G1 = OFF + 7'(BW * g) + 7'd60;
      // H: 64-bit, MSB set.  I: 65 bits -- WIDER THAN 64.
      localparam bit [63:0]       H  = 64'hC000_0000_0000_0000 + 64'(g);
      localparam bit [64:0]       I  = 65'h1_0000_0000_0000_0000 + 65'(g);
      // K: 4-bit, MSB set.
      localparam bit [3:0]        K  = 4'hC + 4'(g);
      // L: genuinely NEGATIVE fold.
      localparam integer          L  = -1 - g;
      // M: structural `*` at the top (INT prefix) with a NON-NEGATIVE fold.
      localparam bit [6:0]        M  = 7'h40 * 1 + g;
      // N: structural `-` at the top with a NEGATIVE fold, MSB-set bits.
      localparam bit [6:0]        N  = 0 - 7'd64 + g;
      // P: UNTYPED.
      localparam                  P  = OFF + 7'(BW * g);
      // Q: a bare REF (no arithmetic).  R: a LITERAL (source-encoded arm).
      localparam bit [6:0]        Q  = OFF;
      localparam bit [6:0]        R  = 7'h40;
      if (A == B && C == 0 && D == J && E == 0 && F == G1 && H == 0 &&
          I == 0 && K == 0 && L == 0 && M == N && P == Q && R == 0) begin : gu
        wire w;
      end
    end
  endgenerate
endmodule
