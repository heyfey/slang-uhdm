// § oobClassTdImporterClass468
// no file-scope import
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
class cmp;
  typedef cmp this_type;
endclass
module top; cmp c; endmodule
