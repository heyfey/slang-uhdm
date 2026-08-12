// r10uvm59 v3_negctl.sv — THE NEGATIVE CONTROL.
//
// NOT ONE type parameter anywhere.  Every `::` here is a scope slang RESOLVES:
// a concrete class static method, a package function, a typedef alias, a
// package enum constant, a class static property, a package parameter, an
// out-of-body (extern) static method, a `::` LVALUE, and a `::`-rooted chain.
// Each of these is owned by an EARLIER law (§ staticScopedCall12,
// § staticScopedRef12, § staticScopedChainDrops48, § staticScopedLvalueBad48,
// § classScopeCallOfOutOfBodyMethodIsFuncCall26).
//
// REQUIREMENT: this arm's `ours.uhdm` must be BYTE-IDENTICAL before and after
// the landed law.  If any cell moves, the new gate is too wide.
package p59v3;
  typedef enum bit [1:0] {E0, E1} e59_t;
  parameter int PAR59 = 7;

  function int pf59(int i);
    return i + 1;
  endfunction

  class base59;
    static int sint;
    static bit sbits[4];
    static function base59 get();
      return null;
    endfunction
    function int inst(int i);
      return i;
    endfunction
    static base59 stat;
  endclass

  typedef base59 alias59;

  class extern59;
    extern static function int eget();
  endclass
  function int extern59::eget();
    return 3;
  endfunction

  class user59;
    static bit m_flag;

    function void c1();
      base59 f = base59::get();
      m_flag = 1;
    endfunction

    function void c2();
      base59 f = alias59::get();
      m_flag = 1;
    endfunction

    function void c3();
      int i = p59v3::pf59(2);
      m_flag = 1;
    endfunction

    function void c4();
      int i = base59::sint;
      m_flag = 1;
    endfunction

    function void c5();
      e59_t e = p59v3::E1;
      m_flag = 1;
    endfunction

    function void c6();
      int i = p59v3::PAR59;
      m_flag = 1;
    endfunction

    function void c7();
      int i = extern59::eget();
      m_flag = 1;
    endfunction

    function void c8();
      base59::sint = 3;
      m_flag = 1;
    endfunction

    function void c9();
      base59::sbits[1] = 1'b1;
      m_flag = 1;
    endfunction

    function void c10();
      int i = base59::stat.inst(2);
      m_flag = 1;
    endfunction

    function void c11();
      int i = base59::get().inst(2);
      m_flag = 1;
    endfunction
  endclass
endpackage
