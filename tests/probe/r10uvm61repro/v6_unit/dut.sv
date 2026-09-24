// r10uvm61 VERIFIER ARM v6_unit — the `$unit`-parameter width, in the only
// place slang allows it: a class declared inside a MODULE (a package may not
// reference a compilation-unit item).  The predicate calls
// `r9DimsLiteral(..., unitResolves=false, ...)`, whose walk answers
// `CompilationUnit -> unitResolves` == FALSE, so our side is predicted to
// KEEP.  Golden's answer is unmeasured by the pass's own grid.
localparam int UW = 5;

module v6_top;
  class un_c;
    logic [UW-1:0] m_uw;      // R1 $unit-parameter width
    logic [3:0]    m_fix;     // R2 control: literal width
    function void r1(ref int o);
      o = $bits(m_uw);
      o = $bits(m_fix);
    endfunction
  endclass
  int o;
  initial begin
    un_c a = new();
    a.r1(o);
  end
endmodule
