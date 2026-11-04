// sister-ground face: a clone body hier_path trailing member select binding (UhdmExporter clone binders)
package p;
  typedef struct packed { logic [7:0] f; logic [7:0] g; } s_t;
  function automatic void f(int i0);
    s_t s;
    s.f[i0+:4] = 1;
  endfunction
endpackage
module top;
  import p::*;
endmodule
