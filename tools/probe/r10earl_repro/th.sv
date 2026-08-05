// r10earl7 witness th — the ranked-(1) class: golden carries a ref_typespec
// on a FOLDED CONSTANT inside a MODULE-LOCAL localparam's Rhs operation; we
// leave the constant bare.  Census (5 AllModules heads):
//   ref_typespec '' :0:0  vs  <null>
//   alert_handler_ping_timer:140:37 (constant under a part_select in a CA)
//   dm_csrs:91:71   `dm::dm_csr_e'((dm::Data0 + {4'b0, dm::DataCount}))`
//   dm_mem:65:64    `(dm::DataAddr - 4*dm::ProgBufSize)`
//   flash_phy_pkg:43:53 `WidthMultiple == 1 ? 1 : LsbAddrBit`
//   pinmux:54:23    `{pinmux_reg_pkg::NMioPeriphOut{1'b1}}`
// Every chain ends in a param_assign Rhs and the constant is always the
// FOLDED VALUE OF A PACKAGE-PARAMETER READ.
package thp;
  localparam int NPeriph  = 32;
  localparam int Cnt      = 2;
  localparam int Base     = 12'h380;
  localparam int Sz       = 8;
  typedef enum logic [11:0] { CSR0 = 12'h04, CSR1 = 12'h10 } csr_e;
endpackage

// pinmux writes `module pinmux import pinmux_pkg::*; import
// pinmux_reg_pkg::*;` AND reads `pinmux_reg_pkg::NMioPeriphOut` QUALIFIED, so
// the witness carries the import too: the materialized copy must not suppress
// the stamp.
module th import thp::*; (
  input  logic        clk_i,
  output logic [31:0] z_o
);
  // pinmux row — a REPLICATION whose count is a qualified package-param read
  localparam logic [thp::NPeriph-1:0] RepRow = {thp::NPeriph{1'b1}};
  // dm_mem row — an arithmetic operation over two qualified reads
  localparam logic [11:0]             ArithRow = (thp::Base - 4*thp::Sz);
  // dm_csrs row — a TYPE CAST over an operation with a concat operand
  localparam thp::csr_e               CastRow  =
      thp::csr_e'((thp::CSR0 + {4'b0, thp::Cnt[3:0]}));
  // flash_phy_pkg row — a ternary over package params
  localparam int                      TernRow  =
      (thp::Cnt == 1) ? 1 : thp::Sz;
  // CONTROL — a module-local read (no package)
  localparam int                      LocalN   = 4;
  localparam logic [3:0]              LocalRow = {LocalN{1'b1}};

  assign z_o = {28'b0, ArithRow[3:0]} ^ {28'b0, LocalRow} ^
               {24'b0, CastRow[7:0]} ^ TernRow ^ RepRow;
endmodule
