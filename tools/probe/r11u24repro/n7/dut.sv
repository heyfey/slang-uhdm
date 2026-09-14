// n7 — THE NESTED LEFTOVER'S ENCODING, one first-level member per RHS shape.
package pk;
  typedef struct packed { int unsigned a; int unsigned b; } in_t;
  typedef struct packed {
    in_t p;   // nested write, LITERAL rhs
    in_t q;   // nested write, TERNARY rhs
    in_t r;   // nested write, PARAMETER read rhs
    in_t t;   // nested write, CONCAT rhs
    in_t z;   // nested write, FORMAL whole read rhs
  } big_t;
  localparam int unsigned KP = 21;
  function automatic big_t mk(int unsigned xa);
    big_t c;
    c.p.a = 5;
    c.q.a = (KP > 3) ? 8 : 9;
    c.r.a = KP;
    c.t.a = {16'h0, 16'h3};
    c.z.a = xa;
    return c;
  endfunction
  localparam big_t C = mk(77);
endpackage

module kid #(
    parameter pk::big_t CFG = pk::C
) (output logic o);
  localparam pk::in_t QP = CFG.p;
  localparam pk::in_t QQ = CFG.q;
  assign o = ^{QP[0], QQ[0]};
endmodule

module dut(output logic o);
  kid k0 (.o(o));
endmodule
