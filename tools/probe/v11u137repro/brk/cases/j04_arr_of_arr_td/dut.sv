// § defNetScopedPkgArrTdShares137
package pkg;
  typedef logic [1:0] a;
  typedef a b [2];
  typedef b cc [3];
endpackage
module dut(output o);
  pkg::cc x;
  assign x[0][1] = 2'd1;
  assign o = x[0][1][0];
endmodule
