// v11v53 BREAK-15: the colliding type reaches the module through a CHAIN of
// wildcard imports (module imports pk2, pk2 imports pk1 which owns the name).
// `Package::append` carries an imported package's data types into the
// importing package's own map, so Surelog sees the name; the fix follows a
// package's own wildcard imports to depth 2 for the same reason.
package pk1;
  typedef logic [7:0] TP;                                         // 8
endpackage
package pk2;
  import pk1::*;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } req_t;  // 8
endpackage
module dut import pk2::*; #(
    parameter type TP = pk2::req_t
) (
    output logic o
);
  localparam int W = $bits(TP);
  localparam int C = $bits(pk2::req_t);   // CONTROL
  assign o = ^{W[0], C[0]};
endmodule
