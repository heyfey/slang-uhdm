// § defNetScopedPkgArrTdShares137
// case sd04: two nets of a package-scoped struct array typedef on separate lines
package sp8;
  typedef struct packed { logic x; logic y; } a;
  typedef a b[2:0];
endpackage
module dut(output o);
  sp8::b c;
  sp8::b d;
  assign c[0].x = 1;
  assign d[0].y = c[0].x;
  assign o = d[0].y;
endmodule
