// v7 — THE MODULE HOLDER.  The builder initialises a MODULE localparam (not a
// package one) and the module hands it down by bare reference.
package p;
  typedef struct packed {
    int unsigned a;
    bit f1;
    bit f2;
  } ucfg_t;
  typedef struct packed {
    ucfg_t u;
    int unsigned d;
  } cfg_t;
  function automatic ucfg_t setc();
    ucfg_t c;
    c.a = 7;
    c.f1 = 1'b1;
    c.f2 = 1'b0;
    return c;
  endfunction
  function automatic cfg_t build(input ucfg_t u);
    cfg_t r;
    r.u = u;
    r.d = u.a * 2;
    return r;
  endfunction
endpackage

module leaf #(
  parameter p::cfg_t Cfg = '0
) (
  input  logic x,
  output logic y
);
  assign y = Cfg.u.f1 ? x : 1'b0;
endmodule

module top (
  input  logic x,
  output logic y
);
  localparam p::ucfg_t U = p::setc();
  localparam p::cfg_t  L = p::build(U);
  leaf #(.Cfg(L)) u_l (.x(x), .y(y));
endmodule
