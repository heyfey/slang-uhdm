// r11u104 arm r2 — THE READING HOMES.  The same narrow reads through every
// road that reaches a net's initializer: the 1-bit net with NO range, a
// delayed net (a literal delay and a NAMED delay — Surelog's writeCont_assign
// skips adjustSize when the delay is a ref), a variable with an initializer,
// an imported (bare) read, a read inside a generate block, a written `assign`,
// a whole-RHS expression over the parameter, a parenthesized read, an explicit
// cast, and a module-local parameter (not this site's road — the control).
package r2p;
  localparam longint BLB  = 9223372036854775807;
  localparam longint BADD = 4294967296 + 1;
  localparam int     CPW  = 2 ** 3;
  localparam int     CLIT = 300;
  localparam logic [11:0] H12 = 12'hABC;
  localparam logic [7:0]  B8  = 8'b1010_1010;
  localparam int     DLY  = 2;
endpackage
module r2_homes104 (output logic [63:0] o);
  import r2p::*;
  wire        wBLB_bare1  = r2p::BLB;
  wire        wCLIT_bare1 = r2p::CLIT;
  wire        wCPW_bare1  = r2p::CPW;
  wire [7:0] #1 wBLB_dly8 = r2p::BLB;
  wire [7:0] #1 wCLIT_dly8 = r2p::CLIT;
  wire [7:0] #(r2p::DLY) wBLB_ndl8 = r2p::BLB;
  wire [7:0] #(r2p::DLY) wCLIT_ndl8 = r2p::CLIT;
  wire [7:0] #(r2p::DLY) wCPW_ndl8 = r2p::CPW;
  logic [7:0] vBLB_var8 = r2p::BLB;
  logic [7:0] vCLIT_var8 = r2p::CLIT;
  logic [7:0] vCPW_var8 = r2p::CPW;
  wire [7:0] wBLB_imp8 = BLB;
  wire [7:0] wCLIT_imp8 = CLIT;
  wire [7:0] wCPW_imp8 = CPW;
  wire [7:0] wBLB_par8 = (r2p::BLB);
  wire [7:0] wCLIT_par8 = (r2p::CLIT);
  wire [7:0] wBLB_add8 = r2p::BLB + 0;
  wire [7:0] wCLIT_add8 = r2p::CLIT + 1;
  wire [7:0] wBLB_cst8 = 8'(r2p::BLB);
  wire [7:0] wCLIT_cst8 = 8'(r2p::CLIT);
  wire [7:0] wH12_n8 = r2p::H12;
  wire [7:0] wB8_n4x = r2p::B8;
  wire [7:0] aBLB_asn8;
  wire [7:0] aCLIT_asn8;
  wire [7:0] aCPW_asn8;
  assign aBLB_asn8 = r2p::BLB;
  assign aCLIT_asn8 = r2p::CLIT;
  assign aCPW_asn8 = r2p::CPW;
  localparam longint MLB = 9223372036854775807;
  localparam int MLIT = 300;
  wire [7:0] wMLB_mod8 = MLB;
  wire [7:0] wMLIT_mod8 = MLIT;
  if (1) begin : g
    wire [7:0] wBLB_gen8 = r2p::BLB;
    wire [7:0] wCLIT_gen8 = r2p::CLIT;
    wire [7:0] wCPW_gen8 = r2p::CPW;
  end
  assign o = {wBLB_bare1, wCLIT_bare1, wCPW_bare1, wBLB_dly8, wCLIT_dly8,
              wBLB_ndl8, wCLIT_ndl8, wCPW_ndl8, vBLB_var8, vCLIT_var8,
              vCPW_var8, wBLB_imp8, wCLIT_imp8, wCPW_imp8, wBLB_par8,
              wCLIT_par8, wBLB_add8, wCLIT_add8, wBLB_cst8, wCLIT_cst8,
              wH12_n8, wB8_n4x, aBLB_asn8, aCLIT_asn8, aCPW_asn8, wMLB_mod8,
              wMLIT_mod8, g.wBLB_gen8, g.wCLIT_gen8, g.wCPW_gen8};
endmodule
