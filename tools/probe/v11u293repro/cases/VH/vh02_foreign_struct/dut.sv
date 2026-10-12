// § pkgHoistArrNetElemDimSpan293
// An array of a struct typedef from another package.
package pa;
  typedef struct packed { logic [3:0] a; logic b; } st_t;
endpackage
package pk;
  pa::st_t v [0:1];
endpackage
module top (output logic o);
  import pk::*;
  assign o = v[1].b;
endmodule
