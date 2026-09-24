// § defNetScopedPkgArrTdShares137
// case sd03: an ascending-range package array typedef, a variable with a pattern initializer
package sp4;
  typedef struct packed { logic a; logic b; } s_t;
  typedef s_t sa[0:2];
endpackage
module dut(output logic o);
  sp4::sa c = '{default: '0};
  assign o = c[1].b;
endmodule
