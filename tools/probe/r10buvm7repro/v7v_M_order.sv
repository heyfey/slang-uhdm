// vbuvm7 arm M — mint ORDER and mint SPAN when a plain read shares the name.
package pkM;
  typedef struct { int used; } stM_t;
  class cM;
    stM_t crr[4];
    stM_t drr[4];
    stM_t err[4];
    int   r;
    extern function void f();
  endclass
  function void cM::f();
    r = crr[0].used;        // M1 plain READ of crr FIRST
    crr[1].used++;          // M2 then the collapse
    drr[1].used++;          // M3 collapse FIRST
    r = drr[0].used;        // M4 then a read
    err[1].used++;          // M5 two collapses, same name
    err[2].used++;          // M6
  endfunction
endpackage
module topM;
  import pkM::*;
  cM h;
  initial begin h = new(); h.f(); end
endmodule
