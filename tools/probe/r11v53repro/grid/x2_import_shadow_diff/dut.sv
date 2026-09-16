// v11u53 BREAK-2: same shadowing face, DIFFERENT widths, so the two candidate
// answers are distinguishable by value (local type parameter = 97, imported
// package typedef = 12).
package pk;
  typedef struct packed { logic [31:0] a; logic [63:0] d; logic w; } req_t; // 97
  typedef logic [11:0] TP;                                                  // 12
endpackage
module dut import pk::*; #(
    parameter type TP = pk::req_t
) (
    output logic o
);
  localparam int W = $bits(TP);
  localparam int C = $bits(pk::req_t);   // CONTROL
  assign o = ^{W[0], C[0]};
endmodule
