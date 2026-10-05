// § ppStrEndNotTokStart251 (an escaped quote in a stringification)
`define D(F) $display(`"F `\`"q`\`"`", x);
module top;
  int x;
  initial `D(ab)
endmodule
