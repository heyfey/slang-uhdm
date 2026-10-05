// § ppStrEndNotTokStart251 (a CRLF file: the stringified end lands on the reference)
`define D(F) $display(`"F`", x);
module top;
  int x;
  initial `D(abcde)
endmodule
