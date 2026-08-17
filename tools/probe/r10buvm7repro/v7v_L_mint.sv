// vbuvm7 arm L — the SECOND law: the hoisted-class-body net mint and its SPAN.
package pkL;
  typedef struct { int used; int c; } stL_t;
  class cL;
    stL_t arr[4];
    stL_t brr[4];
    int   plainv;
    extern function void f();
    extern function void g();
  endclass
  function void cL::f();
    arr[1].used++;            // L1 collapsed ref -> mint at WHOLE lvalue span
    plainv++;                 // L2 plain ref -> mint at the NAME span
  endfunction
  function void cL::g();
    brr[2].c = 3;             // L3 not inc/dec: mint at whatever golden says
    brr[3].c++;               // L4 second inc/dec on an already-minted name
  endfunction
endpackage
module topL;
  import pkL::*;
  cL h;
  initial begin h = new(); h.f(); h.g(); end
endmodule
