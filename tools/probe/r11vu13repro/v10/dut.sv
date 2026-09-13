// v10 — THE CHAIN THROUGH A NARROWER-TYPED HOP.  M is a 34-bit read of the
// 66-bit family base; D reads M whole at the base's own type.  What does the
// producer stamp at each hop?
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

module sink #(
  parameter p::ucfg_t Q = '0
) (
  input  logic x,
  output logic y
);
  assign y = Q.f1 ? x : 1'b0;
endmodule

module top (
  input  logic x,
  output logic y,
  output logic z
);
  localparam p::ucfg_t M = p::C;   // NARROWER read of the base
  localparam p::cfg_t  D = M;      // read of the narrower hop at the base type
  sink #(.Q(M)) u_s (.x(x), .y(y));
  assign z = D.u.f1 ? x : 1'b0;
endmodule
