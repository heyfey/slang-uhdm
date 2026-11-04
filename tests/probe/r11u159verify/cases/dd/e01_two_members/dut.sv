// § patLeftoverOrphanCopy151
package pk;
  typedef struct packed { int unsigned X; int unsigned Y; } u_t;
  typedef struct packed { int unsigned X; int unsigned Y; } cfg_t;
  function automatic cfg_t build(u_t c);
    cfg_t r;
    r.X = c.X;
    r.Y = c.Y;
    return r;
  endfunction
  localparam u_t Base = '{X: 32, Y: 16};
endpackage
module top #(parameter pk::cfg_t Cfg = pk::build(pk::Base)) (output logic [Cfg.X-1:0] o, output logic [Cfg.Y-1:0] p);
  assign o = '0;
  assign p = '1;
endmodule
