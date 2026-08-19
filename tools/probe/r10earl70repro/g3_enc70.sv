// r10earl70 arm 3 — MEASUREMENT ONLY.  THE ENCODING half of
// § connPsBoundOuterScopeKeepsRef70: what the kept ref's enum_const clone
// carries, over every written form of the package parameter, read as the LEFT
// bound of a part_select in an ELABORATED port High_conn inside a gen-for.
package ea_earl70;
  parameter int  EDEC  = 16;          // bare decimal, typed int
  parameter      EUNT  = 16;          // bare decimal, UNTYPED
  parameter int  EEXPR = 8 + 8;       // expression init
  parameter [11:0] EHEX = 12'h5A0;    // based HEX, ranged
  parameter [7:0]  EBIN = 8'b10100001;// based BIN, ranged
  parameter [7:0]  EOCT = 8'o37;      // based OCT, ranged
  parameter [7:0]  EDECB= 8'd21;      // based DECIMAL, ranged
  parameter int    ECLG = $clog2(32); // system-call init
  parameter longint ELNG = 40;        // 64-bit typed
  parameter int    ENEG = -4;         // negative
  parameter int    EHEXI = 12'h5A0;   // based HEX with an INT declared type
  parameter        EHEXU = 12'h5A0;   // based HEX, fully untyped
  parameter int    EQ   = 1;
endpackage

module elf_earl70 (
  input [4095:0] r0, input [4095:0] r1, input [4095:0] r2, input [4095:0] r3,
  input [4095:0] r4, input [4095:0] r5, input [4095:0] r6, input [4095:0] r7,
  input [4095:0] r8, input [4095:0] r9,
  input [4095:0] r10, input [4095:0] r11);
endmodule

module e1_earl70 import ea_earl70::*; (input [4095:0] sig, output logic o);
  for (genvar i = 0; i < 2; i++) begin: eg
    elf_earl70 i_e (
      .r0(sig[EDEC-1:EQ]),
      .r1(sig[EUNT-1:EQ]),
      .r2(sig[EEXPR-1:EQ]),
      .r3(sig[EHEX-1:EQ]),
      .r4(sig[EBIN-1:EQ]),
      .r5(sig[EOCT-1:EQ]),
      .r6(sig[EDECB-1:EQ]),
      .r7(sig[ECLG-1:EQ]),
      .r8(sig[ELNG-1:EQ]),
      .r9(sig[EDEC-1:ENEG+8]),
      .r10(sig[EHEXI-1:EQ]),
      .r11(sig[EHEXU-1:EQ])
    );
  end
  assign o = sig[0];
endmodule

module etop_earl70 (input [4095:0] sig, output logic o);
  e1_earl70 i_e1 (.sig(sig), .o(o));
endmodule
