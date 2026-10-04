// § oobClassTdFirstClassKey231 — the method's class first in the file, the other class's key first
package p;
  class lib #(type REQ=int, RSP=REQ);
    typedef lib#(REQ,RSP) this_type;
    extern static function bit m_check(int seq_type, this_type l);
  endclass
  function bit lib::m_check(int seq_type, this_type l);
    return 0;
  endfunction
  class cmpA #(type B=int, type A=int);
    typedef cmpA#(B, A) this_type;
  endclass
endpackage
module top;
endmodule
