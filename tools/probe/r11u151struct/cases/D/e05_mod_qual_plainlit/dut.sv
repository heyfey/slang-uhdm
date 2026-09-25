// D: the module holder, qualified argument, a plain unsized literal element.
package pk;
  typedef struct packed { int unsigned X; } u_t;
  typedef struct packed { int unsigned X; } cfg_t;
  function automatic cfg_t build(u_t c);
    cfg_t r;
    r.X = c.X;
    return r;
  endfunction
  localparam u_t Base = '{X: 64};
endpackage
module top #(parameter pk::cfg_t Cfg = pk::build(pk::Base)) (output logic [Cfg.X-1:0] o);
  assign o = '0;
endmodule
