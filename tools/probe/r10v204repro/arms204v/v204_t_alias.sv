// r10v204 arm T — WHICH DECLARED LOOP-VARIABLE KINDS golden binds, surveyed:
// a direct class, a typedef ALIAS of a class, a typedef of a builtin, a typedef
// of a packed vector, an enum typedef, a struct typedef, and a class parameter
// type.  Every loop sits in a NESTED begin block of an out-of-body class method
// in a wildcard-imported package (the minting case).
package quarrytv204;
  class Leaftv204;
    int oretv204;
    function void assaytv204(int v204);
    endfunction
  endclass
  typedef Leaftv204 AliasLeaftv204;
  typedef int MyInttv204;
  typedef logic [7:0] MyVectv204;
  typedef enum { REDtv204, GREENtv204 } MyEnumtv204;
  typedef struct packed { logic [3:0] a204; logic [3:0] b204; } MyStructtv204;

  class Itertv204;
    function Leaftv204 firsttv204();
      return null;
    endfunction
    function Leaftv204 nexttv204();
      return null;
    endfunction
  endclass

  class Adittv204;
    int sinktv204;
    extern function void winzetv204(int seltv204);
  endclass

  function void Adittv204::winzetv204(int seltv204);
    Itertv204 ittv204;
    ittv204 = new();
    if (seltv204 == 1) begin
      for (Leaftv204 cD204 = ittv204.firsttv204(); cD204 != null; cD204 = ittv204.nexttv204())
        cD204.assaytv204(1);
      for (AliasLeaftv204 cA204 = ittv204.firsttv204(); cA204 != null; cA204 = ittv204.nexttv204())
        cA204.assaytv204(2);
      for (MyInttv204 iI204 = 0; iI204 < 4; iI204++)
        this.sinktv204 = iI204;
      for (MyVectv204 vV204 = 0; vV204 < 4; vV204++)
        this.sinktv204 = vV204;
      for (MyEnumtv204 eE204 = REDtv204; eE204 != GREENtv204; eE204 = GREENtv204)
        this.sinktv204 = int'(eE204);
      for (MyStructtv204 sS204 = 0; sS204.a204 < 4; sS204.a204++)
        this.sinktv204 = sS204.b204;
    end
  endfunction
endpackage

package sluicetv204;
  import quarrytv204::*;
  class Flumetv204;
    function void racetv204();
      Adittv204 gatetv204;
      gatetv204 = null;
    endfunction
  endclass
endpackage

module toptv204;
  import sluicetv204::*;
  initial begin
    Flumetv204 f204;
    f204 = new();
    f204.racetv204();
  end
endmodule
