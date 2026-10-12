// § pkgHoistArrNetElemDimSpan293
// An unpacked struct element.
package pk;
  typedef struct { logic [3:0] a; logic b; } us_t;
  us_t v [0:1];
endpackage
module top (output logic o);
  import pk::*;
  assign o = v[0].b;
endmodule
