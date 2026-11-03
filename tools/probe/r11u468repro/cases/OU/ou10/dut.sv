// § oobClassTdImporterClass468
// the package classes named to sort after the compilation-unit class (zaa, zlib)
package p;
  class zaa;
    typedef zaa this_type;
  endclass
  class zlib #(type REQ=int);
    typedef zlib#(REQ) this_type;
    extern static function bit m_check(int s, this_type l);
  endclass
  function bit zlib::m_check(int s, this_type l);
    return 0;
  endfunction
endpackage
import p::*;
class cmp;
  typedef cmp this_type;
endclass
module top; cmp c; endmodule
