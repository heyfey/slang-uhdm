// r10v76 arm a4 -- THE VALUE / ENCODING GRID g2 does not reach.
// NEGATIVE values, 64-bit values, a 2-hop and a 3-hop derived chain, an
// ENUM-typed parameter, a SHIFT, a CAST, a based literal with a size wider
// than 64, a signed based literal, a byte/shortint declared type, and the
// non-integer parameters (real / string) the encoder's isInteger() gate
// silently drops.
package v76a;
  parameter int      A1 = 3;
endpackage
package v76b;
  import v76a::*;
  parameter int      B1 = A1 * 2;          // 2-hop chain  (=6)
  parameter int      B2 = B1 + A1;         // 3-hop chain  (=9)
endpackage
package v76p4;
  import v76b::*;
  typedef enum int { E0 = 0, E1 = 1, E7 = 7 } v76e_t;
  parameter int      NEG  = -5;            // NEGATIVE
  parameter int      NEG2 = 3 - 8;         // NEGATIVE from subtraction
  parameter longint  BIG  = 64'd4294967296;// > 32 bits
  parameter longint  BIGN = -64'sd5;       // NEGATIVE 64-bit
  parameter          UBIG = 64'hFFFF_FFFF_FFFF_FFFF; // UNTYPED 64-bit
  parameter int      SH   = 1 << 3;        // SHIFT
  parameter int      CST  = int'(7.0);     // CAST
  parameter byte     BY   = 8'sd12;        // byte
  parameter shortint SI   = 16'sd300;      // shortint
  parameter bit [95:0] W96 = 96'hDEAD_BEEF_CAFE_BABE_1234_5678; // 96 bits
  parameter v76e_t   EP   = E7;            // ENUM-TYPED
  parameter int      CH3  = B2;            // the 3-hop chain, re-exported
  parameter real     RP   = 1.5;           // NON-INTEGER (isInteger() == false)
  parameter string   SP   = "ab";          // NON-INTEGER
endpackage

module v76val #(parameter int P = 2) (input logic clk, output logic [31:0] o);
  import v76p4::*;
  logic [31:0] r [0:1];
  real         rr;
  string       ss;

  if (P > 0) begin : gv_a
    always_comb begin
      r[0] = '0;
      for (int i = 0; i > NEG;  i--) r[0] = r[0] + 1;
      for (int i = 0; i > NEG2; i--) r[0] = r[0] + 1;
      for (longint i = 0; i < BIG;  i = i + BIG)  r[0] = r[0] + 1;
      for (longint i = 0; i > BIGN; i--)          r[0] = r[0] + 1;
      for (longint i = 0; i < UBIG; i = i + UBIG) r[0] = r[0] + 1;
      for (int i = 0; i < SH;   i++) r[0] = r[0] + 1;
      for (int i = 0; i < CST;  i++) r[0] = r[0] + 1;
      for (int i = 0; i < BY;   i++) r[0] = r[0] + 1;
      for (int i = 0; i < SI;   i++) r[0] = r[0] + 1;
      for (int i = 0; i < W96;  i++) r[0] = r[0] + 1;
      for (int i = 0; i < int'(EP); i++) r[0] = r[0] + 1;
      for (int i = 0; i < CH3;  i++) r[0] = r[0] + 1;
      for (int i = 0; i < v76b::B1; i++) r[0] = r[0] + 1;   // QUALIFIED 2-hop
      rr = 0.0; ss = "";
      for (int i = 0; i < 2; i++) begin
        rr = rr + RP;                                        // real, for BODY
        ss = {ss, SP};                                       // string, for BODY
      end
      repeat (BY) r[0] = r[0] + 1;                           // repeat COUNT
    end
  end

  always_comb begin                     // MODULE-BODY twin: golden folds
    r[1] = '0;
    for (int i = 0; i > NEG;  i--) r[1] = r[1] + 1;
    for (longint i = 0; i < BIG; i = i + BIG) r[1] = r[1] + 1;
    for (int i = 0; i < SH;   i++) r[1] = r[1] + 1;
    for (int i = 0; i < BY;   i++) r[1] = r[1] + 1;
    for (int i = 0; i < W96;  i++) r[1] = r[1] + 1;
    for (int i = 0; i < int'(EP); i++) r[1] = r[1] + 1;
    for (int i = 0; i < CH3;  i++) r[1] = r[1] + 1;
  end

  assign o = r[0] ^ r[1];
endmodule

module v76valtop (input logic clk, output logic [31:0] o1);
  v76val #(2) u_v (.clk(clk), .o(o1));
endmodule
