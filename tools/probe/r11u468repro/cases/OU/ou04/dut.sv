// § oobClassTdImporterClass468
// two compilation-unit classes declare the typedef
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
class zz;
  typedef zz this_type;
endclass
class cmp;
  typedef cmp this_type;
endclass
module top; cmp c; zz z; endmodule
