// a5 — THE OPERAND KINDS under the equal split.  Two first-level members,
// each won by a nested write out of a pattern parameter whose elements are of
// a different kind: plain 32-bit literals, and 8-bit ENUM elements.  Both
// members are 96 bits wide, so `ew` is 48 in both and the enum operands are
// ZERO-EXTENDED from 8 to 48.
package pk;
  typedef enum logic [7:0] { E0 = 8'd5, E1 = 8'd6 } e_t;
  typedef struct packed { int unsigned a; int unsigned b; } in_t;
  typedef struct packed { e_t a; e_t b; } en_t;
  localparam in_t LIT = '{a: 11, b: 22};
  localparam en_t ENP = '{a: E0, b: E1};
  typedef struct packed { in_t v; int unsigned w; }  m1_t;      // 96
  typedef struct packed { en_t v; logic [79:0] w; }  m2_t;      // 96
  typedef struct packed { m1_t p; m2_t q; } c_t;
  function automatic c_t mk();
    c_t c;
    c.p.w = 7;      c.p.v = LIT;
    c.q.w = 80'd8;  c.q.v = ENP;
    return c;
  endfunction
  localparam c_t C = mk();
endpackage

module kid #(
    parameter pk::c_t P = pk::C
) (output logic o);
  localparam pk::m1_t S1 = P.p;
  localparam pk::m2_t S2 = P.q;
  assign o = 1'b0;
endmodule

module dut(output logic o);
  kid k0 (.o(o));
endmodule
