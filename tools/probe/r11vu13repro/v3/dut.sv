// v3 — WIDTH MISMATCH AT THE DEFAULT (R1).  A module parameter of a NARROWER
// struct type defaulted to the family base: the truncation must be golden's.
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

module top (
  input  logic x,
  output logic y,
  output logic z
);
  // WHOLE read of the family base at the base's own type
  localparam p::cfg_t Full = p::C;
  // and a NARROWER typed read of the same base
  localparam p::ucfg_t Cut = p::C;
  assign y = Full.u.f1 ? x : 1'b0;
  assign z = Cut.f1 ? x : 1'b0;
endmodule
