// v9 — THE RE-PASS THROUGH A GRANDCHILD and an EXPLICIT (non-wildcard) import,
// with the same base read whole in the package itself.
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
  localparam cfg_t CW = C;
endpackage

module gkid
  import p::cfg_t;
#(
  parameter cfg_t Cfg = '0
) (
  input  logic x,
  output logic y
);
  assign y = Cfg.u.f1 ? x : 1'b0;
endmodule

module kid
  import p::cfg_t;
#(
  parameter cfg_t Cfg = '0
) (
  input  logic x,
  output logic y
);
  gkid #(.Cfg(Cfg)) u_g (.x(x), .y(y));
endmodule

module top
  import p::cfg_t;
#(
  parameter cfg_t Cfg = p::C
) (
  input  logic x,
  output logic y,
  output logic z
);
  kid #(.Cfg(Cfg))  u_k (.x(x), .y(y));
  kid #(.Cfg(p::CW)) u_k2 (.x(x), .y(z));
endmodule
