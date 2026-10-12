// § pkgHoistArrNetElemDimSpan293
// A named logic wire array with a size dimension.
package pk;
  typedef logic [3:0] n_t;
  wire n_t nw [2];
endpackage
module top (output logic [3:0] o);
  import pk::*;
  assign o = nw[1];
endmodule
