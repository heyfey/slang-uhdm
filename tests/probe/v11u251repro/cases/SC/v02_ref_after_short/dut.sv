// § ppStrEndNotTokStart251 (control: the produced end lands inside the comma gap)
`define D(F) $display(`"F`", x);
module top;
  int x;
  initial `D(abcd)
endmodule
