// § pkgHoistArrNetElemDimSpan293
// The package declared in an included header.
`include "pk.svh"
module top (output logic o);
  import pk::*;
  assign o = v[0].b;
endmodule
