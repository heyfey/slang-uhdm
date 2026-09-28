// § lawSCopyIdOrder186: an Earlgrey-like multi-file design (packages of bare scalar typedefs, eight modules binding them); determinism measured by concurrent runs (drivers/lsdet.sh)
module top (input logic clk);
  m0 u0a (.clk(clk));
  m0 u0b (.clk(clk));
  m1 u1a (.clk(clk));
  m1 u1b (.clk(clk));
  m2 u2a (.clk(clk));
  m2 u2b (.clk(clk));
  m3 u3a (.clk(clk));
  m3 u3b (.clk(clk));
  m4 u4a (.clk(clk));
  m4 u4b (.clk(clk));
  m5 u5a (.clk(clk));
  m5 u5b (.clk(clk));
  m6 u6a (.clk(clk));
  m6 u6b (.clk(clk));
  m7 u7a (.clk(clk));
  m7 u7b (.clk(clk));
endmodule
