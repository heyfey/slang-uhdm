// § defNetScopedPkgArrTdShares137
package pkg;
  typedef struct packed { logic x; } a;
  typedef a b [2][3];
endpackage
module dut(output o);
  pkg::b c;
  assign c[1][2].x = 1;
  assign o = c[1][2].x;
endmodule
