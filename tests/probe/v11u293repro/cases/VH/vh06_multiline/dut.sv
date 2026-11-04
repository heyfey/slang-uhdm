// § pkgHoistArrNetElemDimSpan293
// The dimension on the next line.
package pk;
  typedef struct packed { logic [3:0] a; logic b; } st_t;
  st_t v
    [0:1];
endpackage
module top (output logic o);
  import pk::*;
  assign o = v[0].b;
endmodule
