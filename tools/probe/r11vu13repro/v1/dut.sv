// v1 — OVERRIDE CHAIN VALUE.  mid's Cfg default is p::C but the instance
// OVERRIDES it with p::C2; mid re-passes `Cfg` to leaf.  The re-passed actual
// must carry C2's bits, not the declared default's.
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
  function automatic cfg_t build2(input ucfg_t u);
    cfg_t r;
    r.u = u;
    r.d = u.a * 5;
    return r;
  endfunction
  localparam ucfg_t U = setc();
  localparam cfg_t C = build(U);
  localparam cfg_t C2 = build2(U);
endpackage

module leaf #(
  parameter p::cfg_t Cfg = '0
) (
  input  logic x,
  output logic y
);
  assign y = Cfg.u.f1 ? x : 1'b0;
endmodule

module mid #(
  parameter p::cfg_t Cfg = p::C
) (
  input  logic x,
  output logic y
);
  leaf #(.Cfg(Cfg)) u_l (.x(x), .y(y));
endmodule

module top (
  input  logic x,
  output logic y
);
  mid #(.Cfg(p::C2)) u_m (.x(x), .y(y));
endmodule
