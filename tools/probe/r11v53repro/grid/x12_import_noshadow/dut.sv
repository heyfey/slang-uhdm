// v11u53 CONTROL: an import that does NOT collide with the type parameter's
// name.  The law must still refuse here (golden keeps the call).
package pk;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } req_t;  // 8
  typedef logic [7:0] other_t;
endpackage
module dut import pk::*; #(
    parameter type TP = pk::req_t
) (
    output logic o
);
  localparam int W = $bits(TP);
  localparam int C = $bits(pk::req_t);
  assign o = ^{W[0], C[0]};
endmodule
