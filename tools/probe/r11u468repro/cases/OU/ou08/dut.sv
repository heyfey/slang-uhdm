// § oobClassTdImporterClass468
// only the method's own class declares this_type in the package
package p;
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
  typedef cmp this_type;
endclass
module top; cmp c; endmodule
