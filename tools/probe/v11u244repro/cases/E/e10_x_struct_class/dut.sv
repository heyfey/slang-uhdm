// § cloneBlockArrElemOwnCopy244
package p;
  typedef struct { int a; int b; } st_t;
  class it; int v; endclass
  class fac;
    extern function int emit();
  endclass
  function int fac::emit();
    int r;
    begin
      st_t s[2];
      it h[3];
      string nm[2];
      s[0].a = 1;
      h[0] = new();
      nm[1] = "x";
      r = s[0].a + h[0].v + nm[1].len();
    end
    return r;
  endfunction
endpackage
package q;
  import p::*;
  class u; function void f(); fac x; x = null; endfunction endclass
endpackage
module top; import p::*; import q::*; fac z; u w; initial w = new(); endmodule
