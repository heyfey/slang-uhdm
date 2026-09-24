// § defNetScopedPkgArrTdShares137
package pkg;
  typedef logic [3:0] b [2];
endpackage
module dut(output o);
  pkg::b c;
  assign c[0] = 4'd1;
  assign o = c[0][0];
endmodule
