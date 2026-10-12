// § pkgHoistArrNetElemDimSpan293
// The array declared through a macro.
`define DECL(t, n) t n [0:1];
package pk;
  typedef struct packed { logic [3:0] a; logic b; } st_t;
  `DECL(st_t, v)
endpackage
module top (output logic o);
  import pk::*;
  assign o = v[0].b;
endmodule
