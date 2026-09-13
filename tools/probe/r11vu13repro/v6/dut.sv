// v6 — THE BAIL TWIN of v5 (a member the builder never writes) plus the same
// three read sites.  Nothing may be written; the databases must be
// byte-identical between the two binaries.
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
    return c;               // f2 NEVER written -> the assembler bails
  endfunction
  function automatic cfg_t build(input ucfg_t u);
    cfg_t r;
    r.u = u;
    return r;               // d NEVER written
  endfunction
  localparam ucfg_t U = setc();
  localparam cfg_t C = build(U);
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

module mid
  import p::*;
#(
  parameter cfg_t Cfg = p::C
) (
  input  logic x,
  output logic y
);
  leafa #(.Cfg(Cfg)) u_l (.x(x), .y(y));
endmodule

module top (
  input  logic x,
  output logic y
);
  mid u_m (.x(x), .y(y));
endmodule
