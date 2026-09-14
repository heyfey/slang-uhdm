// n5 — THE BAIL AND ITS FLAT CONTROL.  `mkGap` writes only FIRST-LEVEL members
// and leaves `e` unwritten: golden stamps the two it wrote and the assembler
// BAILS (the Rhs stays a struct_var).  That arm must be IDENTICAL pristine and
// patched — it is the flat family's own unwritten-member gap, not this law's.
// `mkAllNested` writes every first-level member NESTED and must assemble.
package pk;
  typedef struct packed { int unsigned a; int unsigned b; } in_t;
  typedef struct packed { in_t u; int unsigned d; int unsigned e; } c3_t;
  typedef struct packed { in_t u; in_t v; } c4_t;
  function automatic c3_t mkGap();    // FLAT writes, `e` never written
    c3_t c; c.u = '{a: 1, b: 2}; c.d = 64; return c;
  endfunction
  function automatic c4_t mkAllNested();
    c4_t c; c.u.a = 3; c.u.b = 32; c.v.a = 5; c.v.b = 6; return c;
  endfunction
  localparam c3_t CG = mkGap();
  localparam c4_t CA = mkAllNested();
endpackage

module kid #(
    parameter pk::c3_t P1 = pk::CG,
    parameter pk::c4_t P2 = pk::CA
) (output logic o);
  localparam int G1 = P1.d;
  localparam int A1 = P2.v.b;
  assign o = 1'b0;
endmodule

module dut(output logic o);
  kid k0 (.o(o));
endmodule
