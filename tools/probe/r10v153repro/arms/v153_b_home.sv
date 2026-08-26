// r10v153 arm B — MORE HOMES: a nested class in a package, a PROGRAM class,
// an INTERFACE class.  Only the package homes may move.
package pvb153;
  int w_int;
  class Ovb153;
    int w_int;
    extern function void omb153(int p);
  endclass
  function void Ovb153::omb153(int p);
    w_int = p;                    // package home: MOVES
  endfunction
endpackage

program pgb153;
  int w_int;
  class Pvb153;
    int w_int;
    extern function void pmb153(int p);
  endclass
  function void Pvb153::pmb153(int p);
    w_int = p;                    // PROGRAM home: must stay
  endfunction
  Pvb153 hb = new();
  initial hb.pmb153(1);
endprogram

interface ifb153;
  int w_int;
  class Ivb153;
    int w_int;
    extern function void imb153(int p);
  endclass
  function void Ivb153::imb153(int p);
    w_int = p;                    // INTERFACE home: must stay
  endfunction
endinterface
