// v11u53 BREAK-3: a PACKAGE type parameter named PACKAGE-QUALIFIED from a
// module.  getTypespec's paPackage_scope branch (CompileExpression.cpp:4530)
// asks the package's data-type map, which holds typedefs only; the predicate
// asks the ALIAS's parent scope, which is the package.  Both must say KEEP.
package pp;
  typedef struct packed { logic [31:0] a; logic [63:0] d; logic w; } req_t; // 97
  parameter type PT = req_t;
  typedef logic [11:0] small_t;                                             // 12
endpackage
module dut (output logic o);
  localparam int W = $bits(pp::PT);        // package-qualified TYPE PARAMETER
  localparam int C = $bits(pp::small_t);   // CONTROL package typedef
  assign o = ^{W[0], C[0]};
endmodule
