// D: the module holder, qualified argument, a WIDE argument struct (the
// StructParamFuncBodyFieldCompare shape without the computed member).
package pk;
  typedef struct packed { int unsigned X; logic [3:0][63:0] L; } u_t;
  typedef struct packed { int unsigned X; } cfg_t;
  function automatic cfg_t build(u_t c);
    cfg_t r;
    r.X = c.X;
    return r;
  endfunction
  localparam u_t Base = '{X: unsigned'(64), L: 256'({64'b0, 64'b0})};
endpackage
module top #(parameter pk::cfg_t Cfg = pk::build(pk::Base)) (output logic [Cfg.X-1:0] o);
  assign o = '0;
endmodule
