// r10v71 arm v3 — MEASUREMENT ONLY.  The VALUE ENCODING axis at the DIRECT
// gen-for bound, covering the shapes r10earl71's d3 did not measure.
package pz_v71;
  parameter int ZA = 10;
endpackage
package pe_v71;
  typedef logic [15:0] ew_t;
  parameter  int B1  = $bits(ew_t);           // $bits  -- claimed by the guard
  parameter  int B2  = $bits(logic [23:0]);
  parameter  int B3  = $clog2(1024);
  parameter  int B4  = 5 ** 2;                // power
  parameter  int B5  = -(-12);                // double negation
  parameter  int B6  = 12'h5A0;               // HEX literal init
  parameter  int B7  = 8'b1010_0001;          // BIN literal init
  parameter  int B8  = 8'o37;                 // OCTAL literal init
  parameter  int B9  = 8'd21;                 // BASED DECIMAL init
  parameter      B10 = 20;                    // bare untyped
  parameter  int B11 = int'(20);              // cast
  parameter  int B12 = 20 % 7;                // mod
  parameter  int B13 = 20 ^ 0;                // XOR
  parameter  int B14 = ~20 & 63;              // bitwise negate then AND
  parameter  int B15 = pz_v71::ZA >>> 1;      // arithmetic shift right
  parameter  int B16 = {1'b0, 4'd9};          // concat init
  parameter  int B17 = 20 + 8'd4;             // add of literal + based decimal
  parameter  int B18 = (20 - 4) + 0;          // add whose operand is a sub
  parameter  int B19 = 20 > 3 ? 20 : 4;       // ternary
  parameter  int B20 = 20 && 1;               // logical and
  parameter  int B21 = 20 == 20;              // equality
  parameter  int B22 = 40 >> 1;
  parameter  int B23 = signed'(20);
  parameter  int B24 = $unsigned(20);
  parameter longint B25 = 40;
endpackage

module lev71 (
  input [4095:0] e0, input [4095:0] e1, input [4095:0] e2, input [4095:0] e3,
  input [4095:0] e4);
endmodule

module m3_v71 import pe_v71::*; (input [4095:0] sig, output logic [4095:0] o0);
  for (genvar g = 0; g < 2; g++) begin: gfe
    lev71 i0 (.e0(sig[4095:B1]),  .e1(sig[4095:B2]),  .e2(sig[4095:B3]),  .e3(sig[4095:B4]),  .e4(sig[4095:B5]));
    lev71 i1 (.e0(sig[4095:B6]),  .e1(sig[4095:B7]),  .e2(sig[4095:B8]),  .e3(sig[4095:B9]),  .e4(sig[4095:B10]));
    lev71 i2 (.e0(sig[4095:B11]), .e1(sig[4095:B12]), .e2(sig[4095:B13]), .e3(sig[4095:B14]), .e4(sig[4095:B15]));
    lev71 i3 (.e0(sig[4095:B16]), .e1(sig[4095:B17]), .e2(sig[4095:B18]), .e3(sig[4095:B19]), .e4(sig[4095:B20]));
    lev71 i4 (.e0(sig[4095:B21]), .e1(sig[4095:B22]), .e2(sig[4095:B23]), .e3(sig[4095:B24]), .e4(sig[4095:B25]));
  end
  assign o0 = sig;
endmodule
