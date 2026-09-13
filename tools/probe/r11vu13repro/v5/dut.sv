// v5 — THE IMPORT-COPY VIEW SPLIT with TWO importing modules and TWO instances
// of one of them, plus a PACKAGE-internal whole read.  Exercises
// elabParamConst's first-writer-wins at the mint.
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
  localparam int unsigned WA = C.u.a;
endpackage

module leafa
  import p::*;
#(
  parameter cfg_t Cfg = p::C
) (
  input  logic x,
  output logic y
);
  assign y = Cfg.u.f1 ? x : 1'b0;
endmodule

module leafb
  import p::*;
#(
  parameter cfg_t Cfg = C
) (
  input  logic x,
  output logic y
);
  assign y = Cfg.u.f2 ? x : 1'b1;
endmodule

module top (
  input  logic x,
  output logic y,
  output logic z,
  output logic w
);
  leafa u_a (.x(x), .y(y));
  leafa u_a2 (.x(x), .y(z));
  leafb u_b (.x(x), .y(w));
endmodule
