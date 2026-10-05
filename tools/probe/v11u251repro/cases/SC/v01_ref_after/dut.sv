// § ppStrEndNotTokStart251 (the stringified literal's produced end lands on the reference x two tokens later)
`define D(F) $display(`"F`", x);
module top;
  int x;
  initial `D(abcde)
endmodule
