// D: a module parameter default calls a package builder with a
// package-QUALIFIED pattern argument; the member copied from the argument
// (`r.X = c.X`) is stamped on cfg_t.
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
module top #(parameter pk::cfg_t Cfg = pk::build(pk::Base)) (output logic [Cfg.X-1:0] o);
  assign o = '0;
endmodule
