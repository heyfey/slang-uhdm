// § ppStrEndNotTokStart251 (an inactive ifdef branch holding a second definition, the active one landing on the reference)
`ifdef NOPE
`define D(F) $display(`"F`");
`else
`define D(F) $display(`"F`", x);
`endif
module top;
  int x;
  initial `D(abcde)
endmodule
