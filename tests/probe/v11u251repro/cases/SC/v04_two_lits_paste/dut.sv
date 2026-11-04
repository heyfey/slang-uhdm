// § ppStrEndNotTokStart251 (two stringifications with a paste, the first end landing on the second literal)
`define D(F, T) $display(`"F`", `"T``_x`");
module top;
  initial `D(abcde, q)
endmodule
