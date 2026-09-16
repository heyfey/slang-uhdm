// v11v53 CONTROL-14: the imported package exports a VALUE, not a type, under
// the colliding name.  A parameter is not in Surelog's DATA TYPE map, so
// getTypespec still fails and golden still KEEPS -- the fix's `isType()` test
// must not be fooled by the name alone.
package pk;
  typedef struct packed { logic [31:0] a; logic [63:0] d; logic w; } req_t; // 97
  parameter int TP = 4;                   // a VALUE named TP, not a type
endpackage
module dut import pk::*; #(
    parameter type TP = pk::req_t
) (
    output logic o
);
  localparam int W = $bits(TP);
  localparam int C = $bits(pk::req_t);    // CONTROL
  assign o = ^{W[0], C[0]};
endmodule
