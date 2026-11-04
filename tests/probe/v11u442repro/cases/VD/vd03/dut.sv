// § modDynTdDefNetCopy442
module top;
  typedef logic [7:0] a_t [string];
  a_t m, n;
  initial m["x"] = 8'h1;
endmodule
