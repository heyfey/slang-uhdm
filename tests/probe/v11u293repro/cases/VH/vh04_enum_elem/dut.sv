// § pkgHoistArrNetElemDimSpan293
// An array of an enum typedef.
package pk;
  typedef enum logic [1:0] { A, B, C } e_t;
  e_t ea [0:1];
endpackage
module top (output logic [1:0] o);
  import pk::*;
  assign o = ea[0];
endmodule
