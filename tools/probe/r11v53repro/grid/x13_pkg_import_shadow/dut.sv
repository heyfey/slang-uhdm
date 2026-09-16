// v11v53 BREAK-13: the shadowing face inside a PACKAGE that declares a type
// parameter and imports another package exporting the same name.
package pk;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } req_t;  // 8
  typedef logic [7:0] PT;                                          // 8, SAME NAME
endpackage
package pp;
  import pk::*;
  parameter type PT = pk::req_t;
  parameter int  PW = $bits(PT);
  parameter int  PD = $bits(pk::req_t);   // CONTROL
endpackage
module dut (output logic o);
  localparam int M = pp::PW;
  localparam int D = pp::PD;
  assign o = ^{M[0], D[0]};
endmodule
