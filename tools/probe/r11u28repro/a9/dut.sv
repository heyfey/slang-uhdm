// a9 — A REPLICATION-VALUED PARAMETER into a WIDER member.  The producer's
// replication arm (ExprEval.cpp :4930) is the 2-operand
// `vpiMultiConcatOp` / `vpiMultiAssignmentPatternOp` branch: `cnt` copies of
// the element at `mw / cnt` bits each, and it BAILS when `mw % cnt`.  96 / 2
// = 48, so each `32'hAB` would render at 48 bits — unless `reduceExpr` got
// there first.
package pk;
  localparam logic [63:0] REP = {2{32'hAB}};
  typedef struct packed { logic [95:0] u; int unsigned d; } c_t;
  function automatic c_t mk();
    c_t c; c.u = REP; c.d = 64; return c;
  endfunction
  localparam c_t C = mk();
endpackage

module kid #(
    parameter pk::c_t P = pk::C
) (output logic o);
  localparam logic [95:0] S1 = P.u;
  assign o = 1'b0;
endmodule

module dut(output logic o);
  kid k0 (.o(o));
endmodule
