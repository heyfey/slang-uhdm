// m10 — THE FLATTEN CONTROL, NO READER AT ALL.  A package struct-pattern
// localparam nobody evaluates.  `ExprEval::getValue` (UHDM v1.87
// templates/ExprEval.cpp:337-347) flattens a pattern operation IN PLACE only
// when somebody looks the parameter up BY NAME, so this arm says what the
// elaborated Rhs looks like with no lookup at all.
package pk;
  typedef struct packed { int unsigned a; int unsigned b; } in_t;
  localparam in_t UU = '{a: 11, b: 22};
endpackage

module dut(output logic o);
  assign o = 1'b0;
endmodule
