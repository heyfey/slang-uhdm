// § pkgHoistArrNetElemDimSpan293
// A struct array sized by a package parameter.
package pk;
  localparam int N = 3;
  typedef struct packed { logic [3:0] a; logic b; } st_t;
  st_t v [N];
endpackage
module top (output logic o);
  import pk::*;
  assign o = v[0].b;
endmodule
