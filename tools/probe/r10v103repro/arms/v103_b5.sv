// r10v103 arm b5 — NESTED SHELLS and the shapes the patch's third conjunct
// (child kind is Call or Invalid) must NOT capture: a shell whose child is a
// BinaryOp / Assignment / MemberAccess / ElementSelect / Concatenation /
// Conversion, and a shell whose child is itself a shell.  Also the
// trailing-member and chained-call spellings, and a call whose receiver goes
// through the type parameter (residue R-R).  MEASUREMENT ONLY.
package Vb5;
  class Lf5;
    int uu;
    function void put(int aa); uu = aa; endfunction
    function Lf5 self(); return this; endfunction
    function int get(); return uu; endfunction
  endclass
  class Md5;
    Lf5 slot;
    Lf5 farm[4];
    function new(); slot = new(); endfunction
  endclass
  class Nest5 #(type PT = int);
    Md5 bo;
    PT  tp;
    int kk;
    int vec;
    int arr2[4];
    Lf5 el;
    function new(); bo = new(); el = new(); endfunction

    // child of the shell is NOT a Call — must be untouched by the law
    function void Xbin();  kk = tp.conv(kk) + tp.conv(kk);        endfunction
    function void Xand();  if (kk && tp.fld) kk = 1;              endfunction
    function void Xasg();  tp.fld = kk;                           endfunction
    function void Xmem();  kk = tp.fld;                           endfunction
    function void Xsel();  kk = tp.arr[1];                        endfunction
    function void Xcat();  kk = {tp.fld, kk};                     endfunction

    // trailing member after a call / chained calls
    function void Ytrail(); kk = bo.slot.self().uu + tp.conv(kk); endfunction
    function void Ychain(); bo.slot.self().put( tp.conv(kk) );    endfunction
    function void Ychn2();  el.self().put( tp.conv(kk) );         endfunction

    // RECEIVER through the type parameter (R-R)
    function void Zrcv();  tp.bx.slot.put( 34 );                  endfunction
    function void Zrcv2(); tp.put( 35 );                          endfunction

    // part-select and element-select roots
    function void Zps();   bo.farm[2].put( tp.conv(kk) );         endfunction
    function void Zsel();  arr2[ tp.conv(kk) ] = 3;               endfunction
  endclass
endpackage
