// r10vrgg18 grid V1 — ADVERSARIAL rows for § genLpFoldDigitsMathValue18.
// Every row is a shape the implementer's a1/b1 grid does NOT contain and on
// which `mathFold46`'s 128-bit UNTRUNCATED arithmetic can legitimately
// disagree with Surelog's 64-bit `Value` word:
//   * a fold that OVERFLOWS 64 bits (Surelog's LValue IS a 64-bit word);
//   * a reference to a parameter whose OWN value is TRUNCATED by its declared
//     width (mathFold46 recurses into the INITIALIZER, not the value);
//   * a NEGATIVE intermediate under `/` and `%` (128-bit signed vs 64-bit).
module v1_vrgg18;
  parameter int PWO = 8;
  localparam bit [3:0]  T4  = 8'hFF;              // value 15, initializer 255
  localparam bit [7:0]  T8  = 16'h1234;           // value 8'h34, initializer 4660
  localparam int        SI  = 32'hC0000000;
  localparam bit [63:0] BIG = 64'hFFFF_FFFF_FFFF_FFFF;

  genvar g;
  generate
    for (g = 0; g < 2; g++) begin : gs
      // ---- 64-BIT OVERFLOW FAMILY (math value >= 2^64) ----
      localparam bit [63:0] OVA = BIG + 64'd1 + 64'(g);
      localparam bit [63:0] OVM = 64'h8000_0000_0000_0000 * 64'd2 + 64'(g);
      localparam bit [63:0] OVP = 64'd2 ** 64'd64 + 64'(g);
      localparam bit [63:0] OVS = 64'h4000_0000_0000_0000 * 64'd4 + 64'(g);
      // ---- INTERMEDIATE TRUNCATION AT A PARAMETER REFERENCE ----
      localparam bit [7:0]  TRC = T4 + 8'(g);
      localparam bit [7:0]  TRD = T8 + 8'(g);
      // ---- SIGNED DECLARED TYPE CARRYING A BIG UNSIGNED LITERAL ----
      localparam int        SGA = 32'hC0000000 + g;
      localparam int        SGB = SI + g;
      localparam byte       SGC = 8'hC0 + 8'(g);
      localparam shortint   SGD = 16'hC000 + 16'(g);
      localparam longint    SGE = 64'hC000_0000_0000_0000 + 64'(g);
      // ---- NEGATIVE INTERMEDIATE UNDER / AND % ----
      localparam bit [7:0]  DVN = (8'd0 - 8'd8) / 8'd2 + 8'(g);
      localparam bit [7:0]  MDN = (8'd0 - 8'd7) % 8'd4 + 8'(g);
      // ---- PARAMETER-DEPENDENT / $clog2 / TERNARY ----
      localparam bit [7:0]  PDP = PWO * 8'd3 + 8'(g);
      localparam bit [7:0]  CLG = $clog2(200) + 8'(g);
      localparam bit [7:0]  TRN = (g == 0) ? 8'hC0 : 8'h40;
      if (OVA == OVM && OVP == OVS && TRC == TRD && SGA == SGB && SGC == 0 &&
          SGD == 0 && SGE == 0 && DVN == MDN && PDP == CLG && TRN == 0) begin : gu
        wire w;
      end
    end
  endgenerate
endmodule
