// r10earl85 g3 — the vpiOverriden half: does the ELAB param_assign carry
// vpiOverriden when the declared type's range names an overridden parameter?
// Mirrors Earlgrey: a base package of plain parameters, a derived package of
// $clog2 localparams, a parameterless middle module, a parameterised leaf.
package t85;
  parameter int FLASH_BANKS = 2;
  parameter int FLASH_PAGES_PER_BANK = 256;
  parameter int FLASH_WORDS_PER_PAGE = 256;
endpackage

package q85;
  localparam int NumBanks     = t85::FLASH_BANKS;
  localparam int PagesPerBank = t85::FLASH_PAGES_PER_BANK;
  localparam int WordsPerPage = t85::FLASH_WORDS_PER_PAGE;
  localparam int BankW        = $clog2(NumBanks);
  localparam int PageW        = $clog2(PagesPerBank);
  localparam int WordW        = $clog2(WordsPerPage);
  localparam int AddrW        = BankW + PageW + WordW;
endpackage

module leaf85 #(
  parameter int AddrW = 10,
  parameter int WordsPerPage = 256,
  parameter int PagesPerBank = 256
) (input logic [AddrW-1:0] a_i, output logic [AddrW-1:0] o_o);
  localparam int WordsBitWidth = $clog2(WordsPerPage);
  localparam int PagesBitWidth = $clog2(PagesPerBank);
  localparam logic[AddrW-1:0] PageAddrMask = ~(('h1 << WordsBitWidth) - 1'b1);
  localparam logic[AddrW-1:0] BankAddrMask = ~(('h1 << (PagesBitWidth + WordsBitWidth)) - 1'b1);
  assign o_o = a_i & PageAddrMask & BankAddrMask;
endmodule

module mid85 import q85::*; (input logic [AddrW-1:0] a_i, output logic [AddrW-1:0] o_o);
  leaf85 #(
    .AddrW(AddrW),
    .PagesPerBank(PagesPerBank),
    .WordsPerPage(WordsPerPage)
  ) u_leaf (.a_i(a_i), .o_o(o_o));
endmodule

module top85(input logic [16:0] a_i, output logic [16:0] o_o);
  mid85 u_mid (.a_i(a_i), .o_o(o_o));
endmodule
