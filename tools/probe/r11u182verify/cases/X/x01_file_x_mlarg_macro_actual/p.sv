`include "defs.svh"
package p;
  import pa::*;
  typedef struct packed {
    int unsigned A;
    int unsigned B;
  } cfg_t;
  function automatic cfg_t mk(u_t u, int unsigned y);
    cfg_t c;
    c.A = u.a;
    c.B = y;
    return c;
  endfunction
  localparam cfg_t D = mk(`XU,
    5);
endpackage
