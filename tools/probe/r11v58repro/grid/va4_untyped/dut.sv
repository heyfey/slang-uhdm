// v11u58 va4 — THE UNTYPED LHS.  `CompileHelper::expandPatternAssignment`
// returns at once when `tps == nullptr` (CompileHelper.cpp:5217), and `tps` is
// the package parameter's OWN Lhs typespec (CompileExpression.cpp:934-940).  A
// parameter written WITHOUT a declared type, its pattern carrying the type as a
// cast, is the face where golden CANNOT stamp.  U1 is untyped, T1 is the typed
// twin; both are read the same gated way.
package pk;
  typedef struct packed {
    int unsigned A;   // 64
    int unsigned B;   // unsigned'(64)
    logic [7:0]  D;   // 32'(5)
  } u_t;
  typedef struct packed { int unsigned X; logic G; } r_t;
  function automatic r_t build(u_t c);
    r_t r;
    r.X = c.A;
    r.G = (c.B > 0);
    return r;
  endfunction
  localparam       U1 = u_t'{ A: 64, B: unsigned'(64), D: 32'(5) };  // UNTYPED
  localparam u_t   T1 = '{ A: 64, B: unsigned'(64), D: 32'(5) };     // typed twin
endpackage
module dut #(parameter pk::r_t R = pk::build(pk::U1),
             parameter pk::r_t S = pk::build(pk::T1)) (output logic [31:0] o);
  assign o = R.X + S.X;
endmodule
