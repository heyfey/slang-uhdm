// v2 — WIDTH MISMATCH AT THE OVERRIDE.  The formal is a NARROWER packed struct
// than the family base, so the actual `p::C` is truncated.  R2 stamps the
// BASE's size and bits; golden must render the FORMAL's.
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

module narrow #(
  parameter p::ucfg_t Cfg = '0
) (
  input  logic x,
  output logic y
);
  assign y = Cfg.f1 ? x : 1'b0;
endmodule

module top (
  input  logic x,
  output logic y
);
  narrow #(.Cfg(p::C)) u_n (.x(x), .y(y));
endmodule
