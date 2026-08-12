// r10svs7 VERIFIER arm v3 — the LHS half's own product: every SHAPE the
// assignment target can take for a covergroup `new`, because § covergroupNewCall7
// (Lhs half) fires only when `lhs->UhdmType() == uhdmref_obj` and re-parents that
// ref through an artefact `hier_path` named from the ref's OWN VpiName.
//
// J1  implicit-`this` class property inside a NON-constructor method
// J2  explicit `this.` (the § thisSuperNewAssignNoStmt3 boundary, R4)
// J3  a STATIC class property from a static method
// J4  inside a conditional statement (not the block's only/last statement)
// J5  an ESCAPED covergroup identifier (the Lhs half hands ITS name to hier_path)
// J6  an ESCAPED CLASS handle — the IN-LAW control on the very same line of code
module v3;
  bit clk;

  covergroup cgn @(posedge clk);
    cpx: coverpoint clk;
  endgroup

  class kls;
    cgn j1;
    cgn j2;
    static cgn j3;
    cgn j4;
    cgn \esc_j5 ;

    function void m1();
      j1 = new;
    endfunction

    function void m2();
      this.j2 = new;
    endfunction

    static function void m3();
      j3 = new;
    endfunction

    function void m4(bit c);
      if (c)
        j4 = new;
    endfunction

    function void m5();
      \esc_j5 = new();
    endfunction
  endclass

  class hnd;
    int z;
  endclass

  hnd \esc_j6 ;
  initial begin
    \esc_j6 = new();
  end
endmodule
