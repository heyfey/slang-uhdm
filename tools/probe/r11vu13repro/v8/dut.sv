// v8 — NEGATIVE CONTROLS on an ASSEMBLED base: a member SELECT actual, a CAST
// actual, a non-function-built base, and an OPERATION around the reference.
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
  localparam cfg_t G = '{u: '{a: 3, f1: 1'b0, f2: 1'b1}, d: 9};
  localparam int unsigned N = 5;
endpackage

module sink #(
  parameter p::cfg_t Cfg = '0,
  parameter int unsigned W = 1
) (
  input  logic x,
  output logic y
);
  assign y = (Cfg.u.f1 & (W != 0)) ? x : 1'b0;
endmodule

module top (
  input  logic x,
  output logic y,
  output logic z,
  output logic q,
  output logic r
);
  sink #(.W(p::C.u.a))          u_n1 (.x(x), .y(y));   // member SELECT actual
  sink #(.Cfg(p::cfg_t'(p::C))) u_n2 (.x(x), .y(z));   // CAST around the ref
  sink #(.Cfg(p::G))            u_n3 (.x(x), .y(q));   // base NOT func-built
  sink #(.W(p::N))              u_n4 (.x(x), .y(r));   // INT-valued localparam
endmodule
