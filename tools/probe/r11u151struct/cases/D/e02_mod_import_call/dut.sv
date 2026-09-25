// D: the same call spelled through a wildcard import (bare names).
package pk;
  typedef struct packed { int unsigned X; } u_t;
  typedef struct packed { int unsigned X; } cfg_t;
  function automatic cfg_t build(u_t c);
    cfg_t r;
    r.X = c.X;
    return r;
  endfunction
  localparam u_t Base = '{X: 32'd64};
endpackage
module top import pk::*; #(parameter cfg_t Cfg = build(Base)) (output logic [Cfg.X-1:0] o);
  assign o = '0;
endmodule
