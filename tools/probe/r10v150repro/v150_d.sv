// r10v150 arm D — INHERITANCE, TYPEDEF ALIAS and PARAMETERISED roots, plus the
// NAME-root controls (hier_path road) and a builtin-method control that
// § builtinRecvMultiDimStepIsBitSelectChain14 owns and that MUST NOT MOVE.
package pv4;
  class L4; int y = 2; function int mm(int a); return y * a; endfunction endclass
  class Base4;
    extern static function L4 bget();
    function L4 iget(); L4 l = new(); return l; endfunction
    function L4 nxt();  return iget(); endfunction
  endclass
  function L4 Base4::bget(); L4 l = new(); return l; endfunction
  class Der4 extends Base4;
    function L4  iget(); L4 l = new(); l.y = 3; return l; endfunction
    function int d1(); return super.iget().mm(61); endfunction  // super. root
    function int d2(); return this.iget().mm(62);  endfunction  // this.  root
    function int d3(); return iget().mm(63);       endfunction  // bare method root
    function int d4(); return Base4::bget().mm(64); endfunction // BASE-name qualifier
    function int d5(); return Der4::bget().mm(65);  endfunction // DERIVED-name qualifier
  endclass
  typedef Base4 B4alias;
  class G4 #(int N = 1);
    extern static function L4 gg();
  endclass
  function L4 G4::gg(); L4 l = new(); return l; endfunction
endpackage

module TV4;
  import pv4::*;
  Base4 bv;
  Base4 bar[3];
  int   qz[$];
  int q1,q2,q3,q4,q5,q6,q7;
  function int e1(); return B4alias::bget().mm(71); endfunction   // via a TYPEDEF alias
  function int e2(); return G4#(3)::gg().mm(72);    endfunction   // parameterised, explicit
  function int e3(); return G4#()::gg().mm(73);      endfunction   // parameterised, EMPTY #()
  // ---- NAME-ROOT CONTROLS: the hier_path road.  MUST NOT MOVE. ----
  function int n1(); return bv.iget().mm(74);       endfunction   // 3-element hier_path
  function int n2(); return bv.nxt().mm(75);        endfunction
  function int n3(); return bar[1].iget().mm(76);   endfunction   // indexed base
  function int n4(); return bv.iget().y;            endfunction   // trailing property
  function int n5(); return qz.size();              endfunction   // BUILTIN method (§14)
  function int n6(); return qz.sum();               endfunction   // BUILTIN reduction
  // ---- standalone ROOT controls (span references) ----
  function automatic L4 s1(); return Base4::bget(); endfunction
  function automatic L4 s2(); return G4#(3)::gg();  endfunction
  function automatic L4 s3(); return G4#()::gg();    endfunction
  initial begin
    bv = new();
    q1=e1(); q2=e2(); q3=e3(); q4=n1(); q5=n3(); q6=n5(); q7=n6();
  end
endmodule
