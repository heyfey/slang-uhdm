// § ppStrEndNotTokStart251 (a stringifying macro called inside another macro's argument)
`define S(F) `"F`"
`define P(A, B) $display(A, B);
module top;
  int z;
  initial `P(`S(abcdefghijklmnopqrst), z)
endmodule
