// r10v150 arm C — CONTEXTS and ARGUMENT SHAPES.
package pv3;
  class T3;
    int w = 1;
    function int f0();                       return w;         endfunction
    function int f1(int a);                  return w + a;     endfunction
    function int f3(int a, int b, int c);    return w+a+b+c;   endfunction
    task         t1(int a);                  w = a;            endtask
    function void v1(int a);                 w = a + 1;        endfunction
  endclass
  class S3;
    extern static function T3 s0();
    extern static function T3 s1(int p);
    extern static function T3 s3(int p, int q, int r);
    function T3  me(int p); T3 t = new(); t.w = p; return t; endfunction
    extern function int oob();
    function int inb();   return S3::s1(5).f1(6);       endfunction  // in-body home
    function int thisc(); return this.me(7).f3(1,2,3);  endfunction  // this. root, 3-arg method
    function int barec(); return me(8).f0();            endfunction  // bare method root
  endclass
  function T3  S3::s0();                    T3 t = new();                return t; endfunction
  function T3  S3::s1(int p);               T3 t = new(); t.w = p;       return t; endfunction
  function T3  S3::s3(int p,int q,int r);   T3 t = new(); t.w = p+q+r;   return t; endfunction
  function int S3::oob(); return S3::s3(9,10,11).f1(12); endfunction     // OUT-OF-BODY home
  function T3  pfree(int p); T3 t = new(); t.w = p; return t; endfunction
endpackage

module TV3;
  import pv3::*;
  int g1,g2,g3,g4;
  function int w1(int x); return x; endfunction
  // chain as a CALL ARGUMENT whose ARGUMENT is itself a chain
  function int k1(); return w1(S3::s1(21).f1(pfree(22).f1(23))); endfunction
  // chain as a WHILE condition
  function int k2(); int s = 0; while (S3::s0().f1(s) < 3) s++; return s; endfunction
  // BARE root, statement position, method is a TASK
  task k3(); pfree(31).t1(32); endtask
  // BARE root, statement position, method is a VOID function
  task k4(); pfree(33).v1(34); endtask
  // SCOPED root, statement position, method is a TASK
  task k5(); S3::s0().t1(35); endtask
  // for-loop CONDITION and BODY
  function int k6();
    int s = 0;
    for (int i = 0; i < S3::s1(41).f1(0); i++) s += pfree(42).f0();
    return s;
  endfunction
  // THREE instances, THREE different root kinds, one expression
  function int k7(); return S3::s0().f0() + pfree(51).f0() + S3::s3(52,53,54).f0(); endfunction
  // inside a fork arm
  task k8(); fork S3::s0().t1(61); join endtask
  initial begin g1=k1(); g2=k2(); k3(); k4(); k5(); g3=k6(); g4=k7(); k8(); end
endmodule
