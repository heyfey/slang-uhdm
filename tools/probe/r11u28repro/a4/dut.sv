// a4 — OPERAND COUNT THREE, and it DIVIDES.  `i3_t` is a 3-element pattern
// parameter; the first-level member `u` is 120 bits, `mw % n` = 0 and
// `ew` = 40, so golden renders 1 at 40 bits, 2 at 40 bits, 3 at 40 bits —
// nothing like the natural 32/32/32 left-padded into 120.
package pk;
  typedef struct packed { int unsigned a; int unsigned b; int unsigned c; } i3_t;
  typedef struct packed { i3_t v; logic [23:0] w; } m120_t;     // 120 bits
  typedef struct packed { m120_t u; int unsigned d; } c_t;
  localparam i3_t U3 = '{a: 1, b: 2, c: 3};
  function automatic c_t mk();
    c_t c; c.u.w = 24'd7; c.u.v = U3; c.d = 64; return c;
  endfunction
  localparam c_t C = mk();
endpackage

module kid #(
    parameter pk::c_t P = pk::C
) (output logic o);
  localparam pk::m120_t S1 = P.u;
  assign o = 1'b0;
endmodule

module dut(output logic o);
  kid k0 (.o(o));
endmodule
