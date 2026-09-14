// n1 — THE WITNESS (r11u21 grid t9, verbatim shape): a package localparam
// built by a const function that writes NESTED struct members, read back
// whole / nested / under a bit select.
package pk;
  typedef struct packed { int unsigned a; int unsigned b; } in_t;
  typedef struct packed { in_t u; int unsigned d; } c_t;
  function automatic c_t mk();
    c_t c; c.u.a = 3; c.u.b = 32; c.d = 64; return c;
  endfunction
  localparam c_t C = mk();
endpackage

module kid #(
    parameter pk::c_t CFG = pk::C
) (output logic o);
  localparam pk::in_t SUB  = CFG.u;      // WHOLE sub-struct member
  localparam int      DEEP = CFG.u.b;    // nested
  localparam int      BIT0 = CFG.d[0];   // a SELECT of a member
  assign o = ^{SUB[0], DEEP[0], BIT0};
endmodule

module dut(output logic o);
  kid k0 (.o(o));
endmodule
