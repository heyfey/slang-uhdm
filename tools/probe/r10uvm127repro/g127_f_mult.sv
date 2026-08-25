// r10uvm127 grid F — MULTIPLICITY, NESTING and RECURSION inside the
// out-of-body window.  Callees are DPI-C imports (or reach one) so no call
// folds away.  MEASUREMENT ONLY.
package Cantle;
  import "DPI-C" function int foldOne(int seedA);
  import "DPI-C" function int foldTwo(int seedA, int seedB);

  function automatic int recurseOne(int seedA);
    if (seedA <= 0) return foldOne(seedA);
    return recurseOne(seedA - 1);                     // recursion: golden stamps
  endfunction

  class Spandrel;
    int  ownA = 2;
    int  ownArr [3];
    extern function int once1  (int seedA);
    extern function int twice2 (int seedA);
    extern function int thrice3(int seedA);
    extern function int arrIndex(int seedA);
    extern function int recurTop(int seedA);
  endclass

  function int Spandrel::once1  (int seedA);  return foldOne(seedA); endfunction
  function int Spandrel::twice2 (int seedA);  return foldTwo(seedA, seedA); endfunction
  function int Spandrel::thrice3(int seedA);
    return foldTwo(foldOne(seedA), foldOne(ownA));    // nested: the INNER
  endfunction                                          // actuals stamp too
  function int Spandrel::arrIndex(int seedA);
    return foldOne(ownArr[seedA]);                    // a SELECT actual
  endfunction
  function int Spandrel::recurTop(int seedA);
    return recurseOne(seedA);
  endfunction
endpackage

// The same shape written THREE TIMES over with different names, so an agreeing
// cell cannot be an artefact of one spelling.
package Cantle2;
  import "DPI-C" function int weldA(string p1, byte p2);
  class Tiercel;
    extern function int oneA(string p1, byte p2);
    extern function int oneB(string p1, byte p2);
    extern function int oneC(string p1, byte p2);
  endclass
  function int Tiercel::oneA(string p1, byte p2); return weldA(p1, p2); endfunction
  function int Tiercel::oneB(string p1, byte p2); return weldA(p1, p2); endfunction
  function int Tiercel::oneC(string p1, byte p2); return weldA(p1, p2); endfunction
endpackage

module Cantle_top;
  import Cantle::*;
  import Cantle2::*;
  Spandrel sp;
  Tiercel  ti;
  int got;
  int txt;
  initial begin
    sp = new(); ti = new();
    got = sp.thrice3(5);
    txt = ti.oneB("z", 8'h31);
  end
endmodule
