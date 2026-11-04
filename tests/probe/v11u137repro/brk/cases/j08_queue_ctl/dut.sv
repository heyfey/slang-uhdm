// § defNetScopedPkgArrTdShares137
package pkg;
  typedef int b[$];
  typedef int d[];
endpackage
module dut(output int o);
  pkg::b c;
  pkg::d e;
  initial begin c.push_back(1); o = c[0]; end
endmodule
