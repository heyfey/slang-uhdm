// a8 — A CONCAT-VALUED PARAMETER into a WIDER member.  If golden's
// `reduceExpr` reduces the concat to a constant first, the member renders the
// constant left-padded to 96; if it does NOT, the same `mw % n` split applies
// to `vpiConcatOp` (ExprEval.cpp :4953 takes `vpiAssignmentPatternOp ||
// vpiConcatOp` in one arm).  The arm DECIDES which, and it is the R4 face
// under a non-natural width.
package pk;
  localparam logic [63:0] CAT = {32'd3, 32'd4};
  typedef struct packed { logic [95:0] u; int unsigned d; } c_t;
  function automatic c_t mk();
    c_t c; c.u = CAT; c.d = 64; return c;
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
