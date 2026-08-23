// r10uvm103 arm a2 — the HEAD's own shape: a 3-component dotted call statement
// inside a PARAMETERISED class whose transformer type parameter defaults to a
// NON-CLASS, so the innermost call cannot bind (uvm_algorithmic_comparator's
// `comp.before_export.write( m_transformer.transform( b ) )`).
// MEASUREMENT ONLY.
package Qk103;

  class Ex103;
    int ww;
    function void wr(int aa); ww = aa; endfunction
    function int rd(); return ww; endfunction
  endclass

  class Nst103;
    Ex103 inner_ex;
    function new(); inner_ex = new(); endfunction
  endclass

  class Cmp103;
    Ex103 before_ex;
    Nst103 nst;
    function new(); before_ex = new(); nst = new(); endfunction
    function void cwr(int aa); before_ex.ww = aa; endfunction
  endclass

  class Algo103 #(type BEF = int, type XF = int);
    Cmp103 cp;
    XF xfm;
    function new(); cp = new(); endfunction
    // 3 components, argument itself a 2-component call on an UNBINDABLE handle
    function void wrt(input BEF bb);
      cp.before_ex.wr( xfm.xform( bb ) );
    endfunction
    // 3 components, argument a plain formal
    function void wrt2(input BEF bb);
      cp.before_ex.wr( bb );
    endfunction
    // 2 components, argument a plain formal
    function void wrt3(input BEF bb);
      cp.cwr( bb );
    endfunction
    // 4 components
    function void wrt4(input BEF bb);
      cp.nst.inner_ex.wr( bb );
    endfunction
    // 3 components in EXPRESSION position
    function int wrt5(input BEF bb);
      return cp.before_ex.rd() + cp.nst.inner_ex.rd();
    endfunction
  endclass

endpackage
