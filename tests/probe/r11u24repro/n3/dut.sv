// n3 — MIXED whole-member and nested writes into the SAME first-level member,
// in BOTH orders, each builder with its own struct typedef.
package pk;
  typedef struct packed { int unsigned a; int unsigned b; } in_t;
  typedef struct packed { in_t u; int unsigned d; } wn_t;
  typedef struct packed { in_t un; int unsigned dn; } nw_t;
  localparam in_t UU = '{a: 11, b: 22};
  function automatic wn_t mkWN();     // WHOLE then NESTED
    wn_t c; c.u = UU; c.u.a = 3; c.d = 64; return c;
  endfunction
  function automatic nw_t mkNW();     // NESTED then WHOLE
    nw_t c; c.un.a = 3; c.un = UU; c.dn = 64; return c;
  endfunction
  localparam wn_t CWN = mkWN();
  localparam nw_t CNW = mkNW();
endpackage

module kid #(
    parameter pk::wn_t P1 = pk::CWN,
    parameter pk::nw_t P2 = pk::CNW
) (output logic o);
  localparam pk::in_t S1 = P1.u;
  localparam pk::in_t S2 = P2.un;
  assign o = 1'b0;
endmodule

module dut(output logic o);
  kid k0 (.o(o));
endmodule
