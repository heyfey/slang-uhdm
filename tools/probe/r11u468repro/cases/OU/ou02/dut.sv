// § oobClassTdImporterClass468
// control: the compilation-unit class has no typedef of that name
package p;
  class aa;
    typedef aa this_type;
  endclass
  class lib #(type REQ=int);
    typedef lib#(REQ) this_type;
    extern static function bit m_check(int s, this_type l);
  endclass
  function bit lib::m_check(int s, this_type l);
    return 0;
  endfunction
endpackage
import p::*;
class cmp;
  typedef cmp other_t;
endclass
module top; cmp c; endmodule
