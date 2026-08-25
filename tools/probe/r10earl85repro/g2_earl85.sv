// r10earl85 g2 — the head's HOME SHAPE: package params passed through a
// parameterless middle module, exactly as Earlgrey's flash_ctrl does.
package p85;
  parameter int AddrW = 17;
  parameter int WordsPerPage = 256;
  parameter int PagesPerBank = 256;
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

module mid85 import p85::*; (input logic [AddrW-1:0] a_i, output logic [AddrW-1:0] o_o);
  leaf85 #(
    .AddrW(AddrW),
    .PagesPerBank(PagesPerBank),
    .WordsPerPage(WordsPerPage)
  ) u_leaf (.a_i(a_i), .o_o(o_o));
endmodule

module top85(input logic [16:0] a_i, output logic [16:0] o_o);
  mid85 u_mid (.a_i(a_i), .o_o(o_o));
endmodule
