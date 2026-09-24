// r10uvm59 a2_position.sv — AXIS: POSITION of the type-parameter static call.
//
// Every cell is the SAME spelling `Tregistry::get()` in a DIFFERENT syntactic
// position, all inside ONE generic class so the binding is identical.  Plus the
// PARENS axis (`Tregistry::get` with no call at all) and the ARGS axis
// (`Tregistry::getn(1,"a")`), and the NESTED cell the brief names
// (`Tcreator::create_by_type(Tregistry::get(), nm)` — corpus line 562).
//
// PREDICTION: golden gives EVERY cell the same bare unbound ref_obj
// `Tregistry::get`, span = scoped-name start .. final identifier start, and
// DROPS the arguments and everything hung off the call.
package p59a2;

  virtual class base59;
    static function base59 get();
      return null;
    endfunction
    static function base59 getn(int i, string s);
      return null;
    endfunction
    static function base59 create_by_type(base59 w, string s);
      return null;
    endfunction
    function void note(base59 w, string s);
    endfunction
    function bit ok();
      return 1;
    endfunction
    static base59 sprop;
  endclass

  class w59 #(type Tregistry = int, type Tcreator = int);
    // A trailing REAL statement (`m_flag = 1;`) is appended to every body whose
    // only other item is a DECLARATION.  WHY: a subroutine body that is a LONE
    // VariableDeclaration is dropped WHOLESALE by our emitter today
    // ("statement kind: VariableDeclaration", residue R2 in the README) and
    // that drop would confound every cell of THIS axis.  The lone-decl shape is
    // measured on its own in v2_lonedecl.sv.
    static bit m_flag;

    // P1 assignment RHS (the head's own position)
    static function void p1();
      Tregistry a = Tregistry::get();
      m_flag = 1;
    endfunction

    // P2 STATEMENT position, void-called
    static function void p2();
      Tregistry::get();
    endfunction

    // P3 an if CONDITION
    static function void p3();
      if (Tregistry::get() != null) begin
      end
    endfunction

    // P4 a call ARGUMENT
    static function void p4(string nm);
      base59 f = base59::get();
      f.note(Tregistry::get(), nm);
    endfunction

    // P5 NESTED — two type-param calls, one as the other's argument
    static function void p5(string nm);
      Tregistry a = Tcreator::create_by_type(Tregistry::get(), nm);
      m_flag = 1;
    endfunction

    // P6 a RETURN expression
    static function Tregistry p6();
      return Tregistry::get();
    endfunction

    // P7 an OPERAND of a binary operation
    static function bit p7();
      bit b = (Tregistry::get() != null);
      return b;
    endfunction

    // P8 NO PARENS — a plain `::`-scoped reference, not a call
    static function void p8();
      Tregistry a = Tregistry::sprop;
      m_flag = 1;
    endfunction

    // P9 WITH ARGUMENTS
    static function void p9();
      Tregistry a = Tregistry::getn(1, "a");
      m_flag = 1;
    endfunction

    // P10 a CHAIN hung off the call
    static function void p10();
      bit b = Tregistry::get().ok();
      m_flag = 1;
    endfunction

    // P11 inside a FOR body
    static function void p11();
      for (int i = 0; i < 2; i++) begin
        Tregistry a = Tregistry::get();
      end
      m_flag = 1;
    endfunction

    // P12 a CLASS PROPERTY initializer
    Tregistry m_prop = Tregistry::get();

    // P13 an INSTANCE (non-static) method
    function void p13();
      Tregistry a = Tregistry::get();
      m_flag = 1;
    endfunction
  endclass
endpackage
