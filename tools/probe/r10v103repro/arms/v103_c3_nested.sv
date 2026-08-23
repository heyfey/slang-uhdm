// NESTED SHELLS: a statement whose expression is a shell whose child is another
// shell whose child is the call (the recursion the third conjunct allows), and
// the shapes that must NOT re-enter it.
package Pc7;
  class Lf7; int uu; function void put(int a); uu = a; endfunction function int get2(int a); return a; endfunction endclass
  class Md7; Lf7 slot; function new(); slot = new(); endfunction endclass
  class Nx7 #(type PT = int);
    Md7 bo; PT tp; PT tq; int kk;
    function new(); bo = new(); endfunction
    // two unbindable pieces in the SAME argument list
    function void N1(); bo.slot.put( tp.conv(kk) + tq.conv(kk) ); endfunction
    // unbindable receiver AND unbindable argument
    function void N2(); tp.mm.put( tq.conv(kk) );                 endfunction
    // three components, argument is a nested dotted read
    function void N3(); bo.slot.put( tp.a.b.c );                  endfunction
    // the call is the RHS of an assignment inside the statement (not a shell stmt)
    function void N4(); kk = bo.slot.get2( tp.conv(kk) );         endfunction
  endclass
endpackage
