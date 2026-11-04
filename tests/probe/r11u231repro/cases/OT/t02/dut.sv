// § oobClassTdFirstClassKey231 — non-parameterized classes
package p;
  class cmpA;
    typedef cmpA this_type;
    function void f(this_type x); endfunction
  endclass
  class lib;
    typedef lib this_type;
    extern static function bit m_check(int seq_type, this_type l);
  endclass
  function bit lib::m_check(int seq_type, this_type l);
    return 0;
  endfunction
endpackage
module top;
endmodule
