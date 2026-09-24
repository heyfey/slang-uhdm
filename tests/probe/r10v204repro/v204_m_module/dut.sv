// r10v204 arm M — MODULE-BODY and GENERATE-SCOPE for loops, with a
// wildcard-import clone present in the same file so pkgCloneBodyLocals9 is
// NON-EMPTY.  Nothing here is a clone body: none of it may move.
package quarrymv204;
  class Leafmv204;
    int oremv204;
    function void assaymv204(int v204);
    endfunction
  endclass
  class Aditmv204;
    int sinkmv204;
    extern function void winzemv204();
  endclass
  function void Aditmv204::winzemv204();
    Leafmv204 lmv204;
    lmv204 = null;
    begin
      for (Leafmv204 cMv204 = lmv204; cMv204 != null; cMv204 = null)
        cMv204.assaymv204(1);
    end
  endfunction
endpackage

package sluicemv204;
  import quarrymv204::*;
  class Flumemv204;
    function void racemv204();
      Aditmv204 gatemv204;
      gatemv204 = null;
    endfunction
  endclass
endpackage

module topmv204;
  import sluicemv204::*;
  int sinkmv204;
  initial begin
    for (int iMv204 = 0; iMv204 < 4; iMv204++)
      sinkmv204 = iMv204;
  end
  task automatic tmv204;
    for (int jMv204 = 0; jMv204 < 4; jMv204++)
      sinkmv204 = jMv204;
  endtask
  always_comb begin
    for (int lMv204 = 0; lMv204 < 2; lMv204++)
      sinkmv204 = lMv204;
  end
  for (genvar gMv204 = 0; gMv204 < 2; gMv204++) begin : gblkmv204
    initial begin
      for (int kMv204 = 0; kMv204 < 2; kMv204++)
        sinkmv204 = kMv204;
    end
  end
endmodule
