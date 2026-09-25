// D: a control: the PACKAGE holds the built parameter, bare argument.
package pk;
  typedef struct packed { int unsigned X; } u_t;
  typedef struct packed { int unsigned X; } cfg_t;
  function automatic cfg_t build(u_t c);
    cfg_t r;
    r.X = c.X;
    return r;
  endfunction
  localparam u_t Base = '{X: 32'd64};
  localparam cfg_t C = build(Base);
endpackage
module top(output logic [pk::C.X-1:0] o);
  assign o = '0;
endmodule
