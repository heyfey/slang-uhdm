// § defNetScopedPkgArrTdShares137
package pkg;
  typedef struct packed { logic x; } a;
  typedef a b[5:0];
endpackage
module dut(output o);
  pkg::b c;
  pkg::b d;
  assign c[1].x = 1;
  assign d[2].x = 0;
  assign o = c[1].x ^ d[2].x;
endmodule
