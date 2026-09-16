// r11u53 ROAD A — the same argument kind in the two OTHER DesignComponent
// kinds that carry a type parameter: a PACKAGE and a CLASS.  Surelog's
// `Package` and `ClassDefinition` are both `DesignComponent`s, so
// `getTypespec`'s two-map lookup (CompileExpression.cpp:4541-4544) behaves the
// same way there; Surelog's own `ClassScope` test is in road A's blast radius.
package pk;
  typedef struct packed { logic [31:0] a; logic [63:0] d; logic w; } req_t; // 97
endpackage
package pp;
  parameter type PT = pk::req_t;             // package TYPE parameter
  parameter int  PW = $bits(PT);             // -> keep?
  parameter int  PD = $bits(pk::req_t);      // CONTROL
endpackage
module dut (output logic o);
  class cc #(type CT = pk::req_t);
    localparam int CW = $bits(CT);           // class TYPE parameter
    localparam int CD = $bits(pk::req_t);    // CONTROL
  endclass
  localparam int MW = pp::PW;
  localparam int MD = pp::PD;
  assign o = ^{MW[0], MD[0]};
endmodule
