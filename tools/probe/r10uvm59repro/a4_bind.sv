// r10uvm59 a4_bind.sv — AXIS: WHAT THE TYPE PARAMETER IS BOUND TO.
//
// Same spelling `T::get()` in the same position, with the parameter's DEFAULT
// changed cell by cell.  The question this arm settles: does golden's bare
// ref_obj depend on the BINDING at all (it cannot — Surelog resolves nothing
// through `::`), and does OUR side's slang binding change (it does: a binding
// that HAS the method makes slang produce a real CallExpression, which
// § staticScopedCall12 already handles, so the new law must NOT fire there).
//
// B1 int            (the corpus default)     slang: Invalid
// B2 string                                  slang: Invalid
// B3 bit                                     slang: Invalid
// B4 a VIRTUAL class WITHOUT `get`           slang: Invalid
// B5 a class WITH a static `get`             slang: BINDS  -> must not change
// B6 a class WITH a NON-static `get`         slang: ?
// B7 a PARAMETERISED class with `get`        slang: BINDS  -> must not change
// B8 NO DEFAULT at all (`type T`)            slang: ?
// B9 a chained type parameter (`type U = T`) slang: Invalid
package p59a4;

  virtual class nog59;
    function void note(string s);
    endfunction
  endclass

  class hasget59;
    static function hasget59 get();
      return null;
    endfunction
  endclass

  class instget59;
    function instget59 get();
      return null;
    endfunction
  endclass

  class pget59 #(type E = int);
    static function pget59 #(E) get();
      return null;
    endfunction
  endclass

  class b1 #(type T = int);
    static bit m_flag;
    static function void f();
      T a = T::get();
      m_flag = 1;
    endfunction
  endclass

  class b2 #(type T = string);
    static bit m_flag;
    static function void f();
      T a = T::get();
      m_flag = 1;
    endfunction
  endclass

  class b3 #(type T = bit);
    static bit m_flag;
    static function void f();
      T a = T::get();
      m_flag = 1;
    endfunction
  endclass

  class b4 #(type T = nog59);
    static bit m_flag;
    static function void f();
      T a = T::get();
      m_flag = 1;
    endfunction
  endclass

  class b5 #(type T = hasget59);
    static bit m_flag;
    static function void f();
      T a = T::get();
      m_flag = 1;
    endfunction
  endclass

  class b6 #(type T = instget59);
    static bit m_flag;
    static function void f();
      T a = T::get();
      m_flag = 1;
    endfunction
  endclass

  class b7 #(type T = pget59#(int));
    static bit m_flag;
    static function void f();
      T a = T::get();
      m_flag = 1;
    endfunction
  endclass

  class b8 #(type T);
    static bit m_flag;
    static function void f();
      T a = T::get();
      m_flag = 1;
    endfunction
  endclass

  class b9 #(type T = int, type U = T);
    static bit m_flag;
    static function void f();
      U a = U::get();
      m_flag = 1;
    endfunction
  endclass
endpackage
