// § defNetScopedPkgArrTdShares137
package pkg;
  typedef struct packed { logic x; } a;
  typedef a b[5:0];
endpackage
module dut(output o);
  if (1) begin : g
    pkg::b c;
    assign c[1].x = 1;
  end
  assign o = g.c[1].x;
endmodule
