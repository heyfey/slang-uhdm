// n2 — WRITE ORDER inside one first-level member.  n1's two nested writes
// SWAPPED (`mk`, so the member's value comes from the MSB-side field), and a
// builder whose first-level member is written three times (`mk2`).  Each
// builder has its OWN struct typedef: a SHARED one is n10's question.
package pk;
  typedef struct packed { int unsigned a; int unsigned b; } in_t;
  typedef struct packed { in_t u; int unsigned d; } c_t;
  typedef struct packed { in_t u2; int unsigned d2; } c2_t;
  function automatic c_t mk();
    c_t c; c.u.b = 32; c.u.a = 3; c.d = 64; return c;
  endfunction
  localparam c_t C = mk();
  function automatic c2_t mk2();
    c2_t c; c.d2 = 64; c.u2.a = 7; c.u2.b = 9; c.u2.a = 5; return c;
  endfunction
  localparam c2_t C2 = mk2();
endpackage

module kid #(
    parameter pk::c_t  CFG  = pk::C,
    parameter pk::c2_t CFG2 = pk::C2
) (output logic o);
  localparam pk::in_t S1 = CFG.u;
  localparam pk::in_t S2 = CFG2.u2;
  localparam int      A1 = CFG.u.a;
  localparam int      A2 = CFG2.u2.a;
  assign o = 1'b0;
endmodule

module dut(output logic o);
  kid k0 (.o(o));
endmodule
