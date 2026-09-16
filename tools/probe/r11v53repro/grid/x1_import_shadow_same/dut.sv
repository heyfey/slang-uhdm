// v11u53 BREAK-1: a WILDCARD IMPORT brings a package typedef whose NAME is the
// module's own type parameter.  slang resolves the bare name to the LOCAL type
// parameter; Surelog's importPackage (CompileHelper.cpp:168) has inserted the
// package typedef into the SAME component data-type map getTypespec reads
// (CompileExpression.cpp:4542), so the producer may resolve and FOLD where the
// law refuses.  The two types are the SAME WIDTH (8) so a fold is the RIGHT
// answer on both sides and any shape change is a regression, not a value bug.
package pk;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } req_t;  // 8
  typedef logic [7:0] TP;                                          // 8, SAME NAME
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
