// r10v103 arm b3 — THE PATCH'S BLAST RADIUS BEYOND A USER DOTTED CALL.
// Every statement here is an ExpressionStatement whose expression slang wraps
// in a bad-expression shell BECAUSE ONE ARGUMENT goes through an unspecialised
// type parameter.  The CHILD of the shell is, in turn: a SYSTEM call
// ($display/$sformat/$cast/$fwrite), a BUILT-IN method call on a queue /
// string / associative array (a SystemSubroutine whose receiver hides in
// arguments()[0] -- the `stmtCtx && !recvText.empty()` arm), a call named
// after the enclosing FUNCTION'S RETURN VARIABLE (retNameRecvCollapse69), a
// plain undotted user call, and a `void'()` cast.  Under
// § invalidShellKeepsStmtPos103 every one of these now sees a statement flag
// it did not see before.  MEASUREMENT ONLY.
package Vb3;

  class Lf3;
    int uu;
    function void put(int aa); uu = aa; endfunction
  endclass

  class Sys3 #(type PT = int);
    PT     tp;
    int    kk;
    int    q[$];
    int    aa[int];
    string ss;
    Lf3    el;
    bit    bb;
    int    dst;
    function new(); el = new(); endfunction

    // ---- SYSTEM calls in statement position with an unbindable argument ----
    function void Ydsp();  $display("%0d", tp.conv(kk));            endfunction
    function void Ydsp2(); $display(tp.conv(kk));                   endfunction
    function void Ysfm();  $sformat(ss, "%0d", tp.conv(kk));        endfunction
    function void Ycst();  void'($cast(dst, tp.conv(kk)));          endfunction
    function void Yfw();   $fwrite(32'h8000_0001, "%0d", tp.conv(kk)); endfunction
    // ---- the SAME system calls with everything bindable (control) ----
    function void Ndsp();  $display("%0d", kk);                     endfunction
    function void Nsfm();  $sformat(ss, "%0d", kk);                 endfunction

    // ---- BUILT-IN method calls in statement position ----
    function void Ypsh();  q.push_back( tp.conv(kk) );              endfunction
    function void Ydel();  aa.delete( tp.conv(kk) );                endfunction
    function void Yito();  ss.itoa( tp.conv(kk) );                  endfunction
    function void Npsh();  q.push_back( kk );                       endfunction

    // ---- a plain UNDOTTED user call ----
    function void Yusr();  el.put( tp.conv(kk) );                   endfunction
    function void Ybare(); putloc( tp.conv(kk) );                   endfunction
    function void putloc(int vv); kk = vv; endfunction

    // ---- void'() over a dotted call with an unbindable argument ----
    function void Yvoid(); void'( tp.conv(kk) );                    endfunction

    // ---- the shell as a NON-statement (expression position control) ----
    function int  Yexp();  return kk + tp.conv(kk);                 endfunction
    function void Yasg();  kk = tp.conv(kk);                        endfunction
    function void Ycond(); if (tp.conv(kk)) kk = 1;                 endfunction
    function void Yter();  kk = (bb ? tp.conv(kk) : 0);             endfunction
    function void Yarg();  el.put( 1 + tp.conv(kk) );               endfunction
  endclass

  // ---- retNameRecvCollapse69: the receiver IS the function return var ----
  typedef int iq3_t[$];
  class Ret3 #(type PT = int);
    PT tp; int kk;
    function iq3_t rq(); rq.push_back( tp.conv(kk) ); endfunction
    function iq3_t rn(); rn.push_back( kk ); endfunction
  endclass

endpackage
