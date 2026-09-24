// r10uvm61 VERIFIER ARM v1_pkgparam — THE CELL THE IMPLEMENTER'S GRID NEVER
// BUILT.  c4_edge tests widths that depend on a CLASS parameter.  It never
// tests a width that depends on a PACKAGE parameter, a `$unit` parameter, or
// a package-level typedef whose own bound reads one.
//
// This matters because the predicate reuses `r9DimsLiteral(..., unitResolves
// = false, bodyResolves = false)`, and that helper's inner walk answers
//     k == SymbolKind::Package        -> TRUE  (resolved -> fold ALLOWED)
//     k == SymbolKind::CompilationUnit-> unitResolves == false -> fold REFUSED
// so the two package rows are predicted to FOLD and the two $unit rows to
// KEEP.  Whether GOLDEN agrees is unmeasured by the pass.
// ($unit-parameter row REMOVED: slang rejects "cannot reference compilation
//  unit item from within a package" -- the cell CANNOT EXIST inside a package.)

package v1_pkg;
  parameter  int PW  = 6;
  localparam int PLW = 7;
  typedef logic [PW-1:0] pdep_t;       // package typedef, package-param bound
  typedef logic [3:0]    pfix_t;

  class pk_c;
    logic [PW-1:0]  m_pw;              // R1 package PARAMETER width
    logic [PLW-1:0] m_plw;             // R2 package LOCALPARAM width
    pdep_t          m_ptd;             // R3 via a package TYPEDEF
    pfix_t          m_pfx;             // R4 control: fixed package typedef
    logic [3:0]     m_fix;             // R5 control: literal
    function void r1(ref int o);
      o = $bits(m_pw);
      o = $bits(m_plw);
      o = $bits(m_ptd);
      o = $bits(m_pfx);
      o = $bits(m_fix);
    endfunction
  endclass

  // R8: a class parameter that is DEFAULTED and the property width uses a
  // package parameter TIMES nothing -- i.e. an expression over a package param.
  class expr_c;
    logic [PW+PLW-1:0] m_ex;
    function void r3(ref int o);
      o = $bits(m_ex);
    endfunction
  endclass
endpackage

module v1_top;
  import v1_pkg::*;
  int o;
  initial begin
    pk_c a = new(); expr_c c = new();
    a.r1(o); c.r3(o);
  end
endmodule
