// r11u54 arm — LAW D, the SECOND free variable: `wd2`'s package parameter is
// only read as a parameter DEFAULT, while the corpus witness
// (StructParamFuncBodyFieldCompare) is passed WHOLE to a CONST FUNCTION whose
// result initializes a parameter.  `ExprEval::getValue` reduces the argument's
// own elaborated `param_assign` IN PLACE for that call (§ patParamEvalFuncRead26),
// so if the member-width re-stamp rides on THAT reduce, this arm stamps and
// `wd2` does not.  Everything else is `wd2` verbatim.
package pk;
  parameter int unsigned NR = 2;
  typedef struct packed {
    int unsigned         A;   // bare literal 64
    int unsigned         B;   // unsigned'(64)
    int unsigned         C;   // $unsigned(64)
    logic [7:0]          D;   // 32'(5), a SIZE CAST
    int unsigned         E;   // NR + 1, an OPERATION
    logic [NR-1:0][63:0] L;   // SYMBOLIC dim: keeps the tagged tree
  } u_t;
  typedef struct packed { int unsigned X; logic F; } r_t;
  function automatic r_t build(u_t c);
    r_t r;
    r.X = c.A;
    r.F = (c.C > 0);
    return r;
  endfunction
  localparam u_t BASE = '{ A: 64,
                           B: unsigned'(64),
                           C: $unsigned(64),
                           D: 32'(5),
                           E: NR + 1,
                           L: 128'({64'b0, 64'b0}) };
endpackage
module dut #(parameter pk::r_t R = pk::build(pk::BASE)) (output logic [31:0] o);
  assign o = R.X;
endmodule
