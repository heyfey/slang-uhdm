// r10uvm185 VERIFIER arm L — THE QUALIFIER / NAME-CASE / COLLISION AXES.
//
// (a) QUALIFIERS on the `extern` prototype: static, virtual, protected, local,
//     and a virtual OVERRIDE in a derived class.  The patched law reads the
//     MethodPrototypeSymbol; a qualifier that changes which symbol carries the
//     declared type would show here.
// (b) NAME CASE: `Ax185` vs `ax185` vs `aX185`.  The ORDER term is a raw
//     `std::string` `<`, so upper-case sorts BEFORE lower-case; golden's own
//     comparison is the thing under test, and an arm that agrees only because
//     the two happen to sort the same way is not an arm testing the law.
// (c) NAME COLLISION: two classes in one package carrying a typedef of the SAME
//     leaf name, each returned from an `extern` prototype in the other.
package pl185;

  class Ax185;                      // capital A sorts BEFORE every lower-case
    typedef enum { LA0, LA1 } shared_t;
    typedef struct { int c; } cap_rec;
  endclass

  class ax185;
    typedef enum { LB0, LB1 } shared_t;   // SAME leaf name, different owner
    typedef struct { int l; } low_rec;
    extern function Ax185::shared_t  l_cap_shared();
    extern function shared_t         l_own_shared_bare();
    extern function ax185::shared_t  l_own_shared_scoped();
    extern function Ax185::cap_rec   l_cap_rec();
  endclass

  class base_q185;
    typedef enum { LQ0, LQ1 } q_enum;
    extern virtual   function q_enum          l_virtual();
    extern static    function base_q185::q_enum l_static();
    extern protected function q_enum          l_protected();
    extern local     function q_enum          l_local();
    extern           function q_enum          l_plain();
  endclass

  class der_q185 extends base_q185;
    extern virtual function q_enum l_virtual();      // an OVERRIDE, inherited td
  endclass

  function Ax185::shared_t  ax185::l_cap_shared();        endfunction
  function ax185::shared_t  ax185::l_own_shared_bare();   endfunction
  function ax185::shared_t  ax185::l_own_shared_scoped(); endfunction
  function Ax185::cap_rec   ax185::l_cap_rec();           endfunction

  function base_q185::q_enum base_q185::l_virtual();   endfunction
  function base_q185::q_enum base_q185::l_static();    endfunction
  function base_q185::q_enum base_q185::l_protected(); endfunction
  function base_q185::q_enum base_q185::l_local();     endfunction
  function base_q185::q_enum base_q185::l_plain();     endfunction
  function base_q185::q_enum der_q185::l_virtual();    endfunction

endpackage

module top185l;
  pl185::ax185    a;
  pl185::der_q185 d;
  initial begin a = new(); d = new(); end
endmodule
