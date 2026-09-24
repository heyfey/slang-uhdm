// § defNetScopedPkgArrTdShares137
// case sd06: a package-scoped array typedef with non-zero bounds
package spa;
  typedef struct packed { logic z; } a;
  typedef a b[5:2];
endpackage
module dut(output logic o);
  spa::b c;
  assign c[3].z = 1'b1;
  assign o = c[3].z;
endmodule
