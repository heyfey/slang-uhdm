// § pkgHoistArrNetElemDimSpan293
// A two-hop typedef of a vector, wire road.
package pk;
  typedef logic [7:0] w_t;
  typedef w_t w2_t;
  wire w2_t nw [0:1];
endpackage
module top (output logic [7:0] o);
  import pk::*;
  assign o = nw[0];
endmodule
