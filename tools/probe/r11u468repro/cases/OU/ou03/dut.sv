// § oobClassTdImporterClass468
// the compilation-unit class parameterized (the scoreboard comparator shape)
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
class comparator #(type T = int);
  typedef comparator #(T) this_type;
  T m;
endclass
module top; comparator #(byte) c; endmodule
