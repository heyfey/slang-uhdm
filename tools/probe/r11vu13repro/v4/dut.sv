// v4 — THE DEF-VIEW SCOPE-BOUNDARY GATE and the CHAIN.  A def listing resolves
// a PACKAGE read and keeps a SIBLING read symbolic; the chain E = D = p::C
// must be judged on its IMMEDIATE referent.
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
  localparam ucfg_t U = setc();
  localparam cfg_t C = build(U);
endpackage

module holder #(
  parameter p::cfg_t D = p::C,
  parameter p::cfg_t E = D
) (
  input  logic x,
  output logic y
);
  assign y = (D.u.f1 & E.u.f1) ? x : 1'b0;
endmodule

module top (
  input  logic x,
  output logic y
);
  holder u_h (.x(x), .y(y));
endmodule
