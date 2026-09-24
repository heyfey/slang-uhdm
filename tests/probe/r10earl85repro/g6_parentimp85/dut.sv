package p85; localparam int AddrW = 17; localparam int WordsPerPage = 256; endpackage
module leaf85 #(parameter int AddrW = 10, parameter int WordsPerPage = 256) ();
  localparam int WordsBitWidth = $clog2(WordsPerPage);
  localparam logic[AddrW-1:0] PageAddrMask = ~(('h1 << WordsBitWidth) - 1'b1);
endmodule
module mid85 import p85::*; ();
  leaf85 #(.AddrW(AddrW), .WordsPerPage(WordsPerPage)) u_leaf ();
endmodule
module top85(); mid85 u_mid (); endmodule
