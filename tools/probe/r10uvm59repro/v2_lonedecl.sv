// r10uvm59 v2_lonedecl.sv — THE CONFOUND, ISOLATED AND NAMED.
//
// A subroutine body that is a LONE VariableDeclaration is dropped WHOLESALE by
// our emitter today: `noteUnsupportedAt("statement kind: VariableDeclaration")`
// and NO assignment, NO ref_obj, regardless of whether the initializer is a
// type-parameter call, a concrete `::` call or a plain literal.  It is the
// reason a2/a3 append a trailing `m_flag = 1;` to every body.
//
// THIS ARM IS NOT THIS PASS'S SUBJECT.  It is here so the residue is measured,
// named and re-runnable rather than discovered again later.  Every cell must
// behave IDENTICALLY before and after the landed law — including L2, whose
// initializer IS the pass's subject, because the drop happens one level up in
// StmtEmit, before any expression is asked for.
//
// L1 lone decl, plain literal initializer         CONCRETE, no `::` at all
// L2 lone decl, TYPE-PARAMETER `::` initializer   the pass's subject, blocked
// L3 lone decl, CONCRETE `::` initializer         § staticScopedCall12, blocked
// L4 the same three with a trailing statement     the CONTROL: all emit
package p59v2;
  class hasget59;
    static function hasget59 get();
      return null;
    endfunction
  endclass

  class w59 #(type T = int);
    static bit m_flag;

    static function void l1();
      int a = 3;
    endfunction

    static function void l2();
      T a = T::get();
    endfunction

    static function void l3();
      hasget59 h = hasget59::get();
    endfunction

    static function void l4a();
      int a = 3;
      m_flag = 1;
    endfunction

    static function void l4b();
      T a = T::get();
      m_flag = 1;
    endfunction

    static function void l4c();
      hasget59 h = hasget59::get();
      m_flag = 1;
    endfunction
  endclass
endpackage
