// D: StructParamFuncBodyFieldCompare's package and holder, without the
// module's cast/pattern localparam.
package pk;
  parameter int unsigned N = 4;
  typedef struct packed { int unsigned X; int unsigned R; logic [N-1:0][63:0] L; } u_t;
  typedef struct packed { int unsigned X; logic F; } cfg_t;
  function automatic cfg_t build(u_t c);
    cfg_t r;
    r.X = c.X;
    r.F = (c.R > 0) && (c.L > 0);
    return r;
  endfunction
  localparam u_t Base = '{X: unsigned'(64), R: unsigned'(2), L: 256'({64'b0, 64'b0})};
endpackage
module top #(parameter pk::cfg_t Cfg = pk::build(pk::Base)) (output logic [Cfg.X-1:0] o, output logic f);
  assign o = '0;
  assign f = Cfg.F;
endmodule
