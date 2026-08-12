// r10uvm59 a3_scope.sv — AXIS: WHAT THE `::` QUALIFIER IS.
//
// The discriminator question: is golden's bare ref_obj a property of the
// qualifier being a TYPE PARAMETER, or of the reference being UNRESOLVABLE, or
// of `::`-into-a-class in general (which § staticScopedCall12 already covers)?
//
// S1 CONCRETE class, method exists            -> already correct on our side
// S2 TYPE PARAMETER, default int, no method   -> THE SUBJECT (slang: Invalid)
// S3 TYPE PARAMETER bound to a CLASS that HAS the method (slang binds it)
// S4 TYPEDEF ALIAS to a concrete class
// S5 PACKAGE-qualified function (the other arm — keeps func_call + args)
// S6 THREE segments through a type parameter
// S7 a type parameter of the ENCLOSING PACKAGE's other generic class
// S8 an out-of-body (extern) static method through a CONCRETE class
//    (§ classScopeCallOfOutOfBodyMethodIsFuncCall26 — must stay a func_call)
package p59a3;

  function int pf59(int i);
    return i;
  endfunction

  virtual class base59;
    static function base59 get();
      return null;
    endfunction
    function void note(base59 w, string s);
    endfunction
  endclass

  class hasget59;
    static function hasget59 get();
      return null;
    endfunction
  endclass

  typedef base59 alias59;

  class extern59;
    extern static function int eget();
  endclass
  function int extern59::eget();
    return 3;
  endfunction

  class w59 #(type Tregistry = int, type Tcreator = hasget59);
    // Trailing `m_flag = 1;` on every body: see a2_position.sv's note — a LONE
    // VariableDeclaration body is dropped wholesale by our emitter today and
    // would confound this axis.  Measured on its own in v2_lonedecl.sv.
    static bit m_flag;

    // S1 CONCRETE
    static function void s1();
      base59 f = base59::get();
      m_flag = 1;
    endfunction

    // S2 TYPE PARAMETER whose default has no such method — THE SUBJECT
    static function void s2();
      Tregistry a = Tregistry::get();
      m_flag = 1;
    endfunction

    // S3 TYPE PARAMETER bound to a class that HAS it
    static function void s3();
      Tcreator c = Tcreator::get();
      m_flag = 1;
    endfunction

    // S4 TYPEDEF ALIAS to a concrete class
    static function void s4();
      base59 f = alias59::get();
      m_flag = 1;
    endfunction

    // S5 PACKAGE-qualified function call
    static function void s5();
      int i = p59a3::pf59(2);
      m_flag = 1;
    endfunction

    // S6 THREE segments through a type parameter — REMOVED, NOT MEASURABLE:
    // `p59a3::Tregistry::get()` is a slang HARD ERROR ("no member named
    // 'Tregistry' in package 'p59a3'"), so the whole arm produces no database.
    // Recorded, not hidden: this cell is unmeasurable, not equal.

    // S8 an EXTERN / out-of-body static method through a CONCRETE class
    static function void s8();
      int i = extern59::eget();
      m_flag = 1;
    endfunction
  endclass
endpackage
