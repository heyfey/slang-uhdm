// v11u53 BREAK-9: the wildcard import is at COMPILATION-UNIT scope, not in the
// module header.  Does Surelog's data-type map still carry the package type?
package pk;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } req_t;  // 8
  typedef logic [7:0] TP;                                          // 8
endpackage
import pk::*;
module dut #(
    parameter type TP = pk::req_t
) (
    output logic o
);
  localparam int W = $bits(TP);
  localparam int C = $bits(pk::req_t);
  assign o = ^{W[0], C[0]};
endmodule
