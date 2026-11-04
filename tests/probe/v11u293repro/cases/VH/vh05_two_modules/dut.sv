// § pkgHoistArrNetElemDimSpan293
// Two modules import the same array.
package pk;
  typedef struct packed { logic [3:0] a; logic b; } st_t;
  st_t v [0:1];
endpackage
module m1 (output logic o);
  import pk::*;
  assign o = v[0].b;
endmodule
module top (output logic o, output logic o2);
  import pk::*;
  m1 u1 (.o(o));
  assign o2 = v[1].b;
endmodule
