// § defNetScopedPkgArrTdShares137
package pkg;
  typedef struct packed { logic x; } a;
  typedef a b[5:0];
endpackage
interface bus;
  pkg::b c;
endinterface
module dut(output o);
  bus i();
  assign o = i.c[0].x;
endmodule
